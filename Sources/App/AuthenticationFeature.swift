import ComposableArchitecture
import Foundation
import GitHub
import PointFreeRouter

@Reducer
public struct AuthenticationFeature {
  @ObservableState
  public struct State: Equatable {
    public var isAuthenticated = false
    public var isPolling = false
    public var deviceAuthResponse: GitHub.Client.DeviceAuthResponse?
    public var gitHubUser: GitHubUser?
    public var errorMessage: String?
    public var pollingTask: Task<Void, Never>?
    
    public init() {}
    
    public static func == (lhs: State, rhs: State) -> Bool {
      lhs.isAuthenticated == rhs.isAuthenticated &&
      lhs.isPolling == rhs.isPolling &&
      lhs.deviceAuthResponse == rhs.deviceAuthResponse &&
      lhs.gitHubUser == rhs.gitHubUser &&
      lhs.errorMessage == rhs.errorMessage
    }
  }
  
  public enum Action {
    case loginTapped
    case deviceAuthInitiated(GitHub.Client.DeviceAuthResponse)
    case deviceAuthFailed(Error)
    case startPolling
    case pollForAuth
    case authSuccess(GitHubAccessToken)
    case loginResponse(Result<GitHubUser, Error>)
    case logoutTapped
    case cancelAuth
  }
  
  @Dependency(\.gitHub) var gitHub
  @Dependency(\.continuousClock) var clock
  
  public init() {}
  
  public var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .loginTapped:
        state.isPolling = false
        state.errorMessage = nil
        state.deviceAuthResponse = nil
        
        // Initiate device auth flow
        return .run { send in
          do {
            // Get client ID from environment or hardcode for now
            // In production, this should come from environment/config
            let clientId = GitHub.Client.ID(rawValue: "Iv1.b507a08c87ecfe98")
            let response = try await gitHub.initiateDeviceAuth(clientId, "repo user")
            await send(.deviceAuthInitiated(response))
          } catch {
            await send(.deviceAuthFailed(error))
          }
        }
        
      case let .deviceAuthInitiated(response):
        state.deviceAuthResponse = response
        return .send(.startPolling)
        
      case let .deviceAuthFailed(error):
        state.errorMessage = error.localizedDescription
        state.isPolling = false
        return .none
        
      case .startPolling:
        guard let response = state.deviceAuthResponse else { return .none }
        state.isPolling = true
        
        // Start polling for authorization
        return .run { send in
          // Wait for the interval before first poll
          try? await clock.sleep(for: .seconds(response.interval))
          
          // Continue polling until authorized or expired
          let clientId = GitHub.Client.ID(rawValue: "Iv1.b507a08c87ecfe98")
          let expirationTime = Date().addingTimeInterval(TimeInterval(response.expiresIn))
          
          while Date() < expirationTime {
            await send(.pollForAuth)
            
            do {
              let tokenResponse = try await gitHub.pollDeviceAuth(clientId, response.deviceCode)
              await send(.authSuccess(tokenResponse.accessToken))
              return
            } catch {
              // Check if it's an authorization_pending error, continue polling
              // Otherwise, treat as failure
              let errorString = String(describing: error)
              if errorString.contains("authorization_pending") || errorString.contains("slow_down") {
                // Continue polling
                try? await clock.sleep(for: .seconds(response.interval))
              } else {
                await send(.deviceAuthFailed(error))
                return
              }
            }
          }
          
          // Expired
          await send(.deviceAuthFailed(NSError(domain: "DeviceAuth", code: -1, userInfo: [
            NSLocalizedDescriptionKey: "Authentication timed out"
          ])))
        }
        
      case .pollForAuth:
        // Action to track polling attempts, no state change needed
        return .none
        
      case let .authSuccess(accessToken):
        state.isPolling = false
        
        return .run { send in
          do {
            let user = try await gitHub.fetchUser(accessToken)
            await send(.loginResponse(.success(user)))
          } catch {
            await send(.loginResponse(.failure(error)))
          }
        }
        
      case let .loginResponse(.success(user)):
        state.isAuthenticated = true
        state.gitHubUser = user
        state.deviceAuthResponse = nil
        return .none
        
      case let .loginResponse(.failure(error)):
        state.errorMessage = error.localizedDescription
        state.isPolling = false
        state.deviceAuthResponse = nil
        return .none
        
      case .logoutTapped:
        state.isAuthenticated = false
        state.gitHubUser = nil
        state.deviceAuthResponse = nil
        state.isPolling = false
        return .none
        
      case .cancelAuth:
        state.isPolling = false
        state.deviceAuthResponse = nil
        return .none
      }
    }
  }
}
