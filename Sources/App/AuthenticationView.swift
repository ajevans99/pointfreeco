import ComposableArchitecture
import GitHub
import SwiftUI

public struct AuthenticationView: View {
  @Bindable public var store: StoreOf<AuthenticationFeature>
  
  public init(store: StoreOf<AuthenticationFeature>) {
    self.store = store
  }
  
  public var body: some View {
    NavigationStack {
      VStack(spacing: 24) {
        if store.isAuthenticated, let user = store.gitHubUser {
          // Authenticated state
          VStack(spacing: 16) {
            Image(systemName: "checkmark.circle.fill")
              .font(.system(size: 64))
              .foregroundColor(.green)
            
            Text("Signed in as")
              .font(.headline)
            
            Text(user.name ?? user.login)
              .font(.title2)
              .fontWeight(.bold)
            
            Button("Sign Out") {
              store.send(.logoutTapped)
            }
            .buttonStyle(.bordered)
          }
          
        } else if let deviceAuth = store.deviceAuthResponse {
          // Device auth in progress
          VStack(spacing: 24) {
            Text("Sign in with GitHub")
              .font(.title)
              .fontWeight(.bold)
            
            VStack(spacing: 12) {
              Text("1. Visit this URL:")
                .font(.headline)
              
              Button(action: {
                if let url = URL(string: deviceAuth.verificationUri) {
                  #if os(iOS) || os(tvOS)
                  UIApplication.shared.open(url)
                  #elseif os(macOS)
                  NSWorkspace.shared.open(url)
                  #endif
                }
              }) {
                Text(deviceAuth.verificationUri)
                  .font(.body)
                  .foregroundColor(.blue)
              }
            }
            
            VStack(spacing: 12) {
              Text("2. Enter this code:")
                .font(.headline)
              
              Text(deviceAuth.userCode)
                .font(.system(size: 48, weight: .bold, design: .monospaced))
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
            }
            
            if store.isPolling {
              VStack(spacing: 8) {
                ProgressView()
                Text("Waiting for authorization...")
                  .font(.caption)
                  .foregroundColor(.secondary)
              }
              .padding(.top)
            }
            
            Button("Cancel") {
              store.send(.cancelAuth)
            }
            .buttonStyle(.bordered)
            .foregroundColor(.red)
          }
          .padding()
          
        } else {
          // Not authenticated
          VStack(spacing: 16) {
            Image(systemName: "person.circle")
              .font(.system(size: 64))
              .foregroundColor(.secondary)
            
            Text("Sign in to Point-Free")
              .font(.title2)
              .fontWeight(.semibold)
            
            Text("Sign in with your GitHub account to access subscriber content")
              .font(.body)
              .foregroundColor(.secondary)
              .multilineTextAlignment(.center)
              .padding(.horizontal)
            
            if let errorMessage = store.errorMessage {
              Text(errorMessage)
                .font(.caption)
                .foregroundColor(.red)
                .multilineTextAlignment(.center)
                .padding()
                .background(Color.red.opacity(0.1))
                .cornerRadius(8)
            }
            
            Button("Sign in with GitHub") {
              store.send(.loginTapped)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
          }
          .padding()
        }
      }
      .frame(maxWidth: .infinity, maxHeight: .infinity)
      .navigationTitle("Account")
    }
  }
}

#Preview {
  AuthenticationView(
    store: Store(initialState: AuthenticationFeature.State()) {
      AuthenticationFeature()
    }
  )
}
