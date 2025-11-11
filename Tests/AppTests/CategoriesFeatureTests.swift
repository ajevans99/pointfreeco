import ComposableArchitecture
import Models
import XCTest

@testable import App

@MainActor
final class CategoriesFeatureTests: XCTestCase {
  func testTask() async {
    let store = TestStore(initialState: CategoriesFeature.State()) {
      CategoriesFeature()
    }
    
    await store.send(.task)
  }
}
