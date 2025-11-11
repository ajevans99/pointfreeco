import ComposableArchitecture
import Foundation
import GitHub

@Reducer
public struct AuthenticationFeature {
  @ObservableState
  public struct State: Equatable {
    public var isAuthenticated = false
    public var isLoading = false
    public var gitHubUser: GitHubUser?
    public var errorMessage: String?
    
    public init() {}
  }
  
  public enum Action {
    case loginTapped
    case loginResponse(Result<GitHubUser, Error>)
    case logoutTapped
  }
  
  @Dependency(\.github) var github
  
  public init() {}
  
  public var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .loginTapped:
        state.isLoading = true
        state.errorMessage = nil
        // In a real implementation, this would trigger OAuth flow
        // For now, we'll just simulate a login
        return .run { send in
          // Simulate GitHub OAuth flow
          // In production, this would:
          // 1. Open GitHub OAuth URL
          // 2. Handle callback with code
          // 3. Exchange code for access token
          // 4. Fetch user with access token
          do {
            // This is a placeholder - real implementation would use the GitHub client
            // with actual OAuth flow
            let mockUser = GitHubUser(
              id: .init(rawValue: 123),
              name: "Demo User"
            )
            await send(.loginResponse(.success(mockUser)))
          } catch {
            await send(.loginResponse(.failure(error)))
          }
        }
        
      case let .loginResponse(.success(user)):
        state.isLoading = false
        state.isAuthenticated = true
        state.gitHubUser = user
        return .none
        
      case let .loginResponse(.failure(error)):
        state.isLoading = false
        state.errorMessage = error.localizedDescription
        return .none
        
      case .logoutTapped:
        state.isAuthenticated = false
        state.gitHubUser = nil
        return .none
      }
    }
  }
}
