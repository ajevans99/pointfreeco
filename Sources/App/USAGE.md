# Example iOS/tvOS/macOS App Entry Point

This file shows how to create an actual app target that uses the `App` library.

## Creating an Xcode App Target

1. Open your project in Xcode
2. File → New → Target
3. Choose "App" for your desired platform (iOS, tvOS, or macOS)
4. Name it (e.g., "PointFreeTV", "PointFreeiOS", or "PointFreeMac")
5. Add the `App` library as a dependency to your new target

## Example Entry Point Code

### For iOS/iPadOS App

```swift
// PointFreeiOSApp.swift
import App
import ComposableArchitecture
import SwiftUI

@main
struct PointFreeiOSApp: App {
  var body: some Scene {
    WindowGroup {
      AppView(
        store: Store(initialState: AppFeature.State()) {
          AppFeature()
        }
      )
    }
  }
}
```

### For tvOS App

```swift
// PointFreeTVApp.swift
import App
import ComposableArchitecture
import SwiftUI

@main
struct PointFreeTVApp: App {
  var body: some Scene {
    WindowGroup {
      AppView(
        store: Store(initialState: AppFeature.State()) {
          AppFeature()
        }
      )
    }
  }
}
```

### For macOS App

```swift
// PointFreeMacApp.swift
import App
import ComposableArchitecture
import SwiftUI

@main
struct PointFreeMacApp: App {
  var body: some Scene {
    WindowGroup {
      AppView(
        store: Store(initialState: AppFeature.State()) {
          AppFeature()
        }
      )
      .frame(minWidth: 800, minHeight: 600)
    }
  }
}
```

## Configuring Dependencies

If you need to configure GitHub OAuth or other dependencies, you can do so when creating the store:

```swift
import App
import ComposableArchitecture
import GitHub
import SwiftUI

@main
struct PointFreeApp: App {
  var body: some Scene {
    WindowGroup {
      AppView(
        store: Store(initialState: AppFeature.State()) {
          AppFeature()
        } withDependencies: {
          // Configure GitHub client with your OAuth credentials
          $0.gitHub = GitHub.Client(
            clientId: .init(rawValue: "YOUR_GITHUB_CLIENT_ID"),
            clientSecret: .init(rawValue: "YOUR_GITHUB_CLIENT_SECRET")
          )
        }
      )
    }
  }
}
```

## Info.plist Configuration

For GitHub OAuth to work, you'll need to add a URL scheme to your Info.plist:

```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>pointfree</string>
        </array>
        <key>CFBundleURLName</key>
        <string>co.pointfree.auth</string>
    </dict>
</array>
```

And handle the URL callback in your app:

```swift
.onOpenURL { url in
  // Handle OAuth callback
  // Extract code from URL and send to authentication feature
}
```

## Building and Running

Once you've created your app target:

1. Select the target in Xcode
2. Choose a simulator or device
3. Press Cmd+R to build and run

The app will launch with two tabs: Episodes and Categories, featuring an Apple TV-style interface for browsing Point-Free content.
