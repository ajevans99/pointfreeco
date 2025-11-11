# App

A SwiftUI application built with The Composable Architecture (TCA) for browsing Point-Free episodes and collections.

## Overview

The App target provides a cross-platform SwiftUI application for tvOS, iOS, iPadOS, and macOS. It features a tab-based interface similar to the Apple TV app, focusing on video content.

## Features

- **Episodes Tab**: Browse all Point-Free episodes with rich cards showing thumbnails, titles, descriptions, and metadata
- **Categories Tab**: Explore episode collections organized by topic
- **Video Playback**: Stream episode trailers and full videos (for subscribers)
- **GitHub Authentication**: Login using existing GitHub OAuth flow

## Architecture

The app is built using modern TCA patterns:

- `@Reducer` macro for feature reducers
- `@ObservableState` for state management
- Swift Navigation for routing
- Composable, testable feature modules

## Structure

```
App/
├── AppFeature.swift          # Root app reducer and state
├── AppView.swift             # Main tab view
├── EpisodesFeature.swift     # Episodes list logic
├── EpisodesView.swift        # Episodes list UI
├── EpisodeDetailFeature.swift # Single episode logic
├── EpisodeDetailView.swift   # Single episode UI with video player
├── CategoriesFeature.swift   # Categories list logic
├── CategoriesView.swift      # Categories grid UI
├── CollectionDetailFeature.swift # Collection detail logic
├── CollectionDetailView.swift    # Collection detail UI
└── AuthenticationFeature.swift   # GitHub auth logic
```

## Dependencies

- **Models**: Episode and Collection data models
- **GitHub**: Authentication via GitHub OAuth
- **Transcripts**: Episode content and collections
- **ComposableArchitecture**: State management and architecture

## Platform Support

- **tvOS 17+**: Primary target
- **iOS 17+**: Full support
- **iPadOS 17+**: Full support
- **macOS 14+**: Full support

## Building and Running

Since this is a library target, you'll need to create an app target in Xcode that depends on `App`:

1. Create a new app target in Xcode for your desired platform
2. Add `App` as a dependency
3. Import and use `AppView` in your app entry point:

```swift
import App
import ComposableArchitecture
import SwiftUI

@main
struct PointFreeApp: SwiftUI.App {
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

## Testing

Tests are available in the `AppTests` target and cover:

- Tab navigation
- Episode loading and selection
- Collection loading and selection
- State management

Run tests with:
```bash
swift test --filter AppTests
```

Note: Tests require an Apple platform (macOS) as they depend on SwiftUI.

## Future Enhancements

- Full GitHub OAuth flow implementation
- Transcript viewing
- Episode progress tracking
- Offline viewing
- Watch history
- Search functionality
- Filtering and sorting options
