import ComposableArchitecture
import Foundation
import GitHub
import PointFreeRouter

@Reducer
public struct AuthenticationFeature {
  @ObservableState
  public struct State: Equatable {
    public var isAuthenticated = false
    public var isLoading = false
    public var gitHubUser: GitHubUser?
    public var errorMessage: String?
    public var authorizationURL: URL?
    
    public init() {}
  }
  
  public enum Action {
    case loginTapped
    case handleOAuthCallback(code: String)
    case loginResponse(Result<GitHubUser, Error>)
    case logoutTapped
  }
  
  @Dependency(\.gitHub) var gitHub
  @Dependency(\.siteRouter) var siteRouter
  
  public init() {}
  
  public var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .loginTapped:
        state.isLoading = true
        state.errorMessage = nil
        
        // Generate GitHub OAuth URL
        // In a real app, this would open the browser or SafariViewController
        // The redirect URL should match your app's URL scheme (e.g., pointfree://auth/github/callback)
        let authURL = siteRouter.url(for: .auth(.gitHubAuth(redirect: nil)))
        if let url = URL(string: authURL) {
          state.authorizationURL = url
        }
        
        // Note: The actual OAuth flow would be:
        // 1. Open authURL in browser/SafariViewController
        // 2. User authorizes on GitHub
        // 3. GitHub redirects back to your app with a code
        // 4. Handle the callback with handleOAuthCallback action
        
        return .none
        
      case let .handleOAuthCallback(code):
        state.isLoading = true
        state.errorMessage = nil
        
        return .run { send in
          do {
            // Exchange code for access token
            let tokenResponse = try await gitHub.fetchAuthToken(code)
            
            // Fetch user details with the access token
            let user = try await gitHub.fetchUser(tokenResponse.accessToken)
            
            await send(.loginResponse(.success(user)))
          } catch {
            await send(.loginResponse(.failure(error)))
          }
        }
        
      case let .loginResponse(.success(user)):
        state.isLoading = false
        state.isAuthenticated = true
        state.gitHubUser = user
        state.authorizationURL = nil
        return .none
        
      case let .loginResponse(.failure(error)):
        state.isLoading = false
        state.errorMessage = error.localizedDescription
        state.authorizationURL = nil
        return .none
        
      case .logoutTapped:
        state.isAuthenticated = false
        state.gitHubUser = nil
        state.authorizationURL = nil
        return .none
      }
    }
  }
}
