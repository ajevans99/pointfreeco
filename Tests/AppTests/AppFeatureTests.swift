import ComposableArchitecture
import XCTest

@testable import App

@MainActor
final class AppFeatureTests: XCTestCase {
  func testTabSwitching() async {
    let store = TestStore(initialState: AppFeature.State()) {
      AppFeature()
    }
    
    await store.send(.selectedTabChanged(.categories)) {
      $0.selectedTab = .categories
    }
    
    await store.send(.selectedTabChanged(.episodes)) {
      $0.selectedTab = .episodes
    }
  }
}
