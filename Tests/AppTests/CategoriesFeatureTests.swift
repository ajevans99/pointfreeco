import ComposableArchitecture
import Models
import XCTest

@testable import App

@MainActor
final class CategoriesFeatureTests: XCTestCase {
  func testLoadCollections() async {
    let store = TestStore(initialState: CategoriesFeature.State()) {
      CategoriesFeature()
    }
    
    await store.send(.task) {
      $0.isLoading = true
    }
    
    await store.receive(\.collectionsLoaded) {
      $0.collections = Episode.Collection.all
      $0.isLoading = false
    }
  }
  
  func testCollectionSelection() async {
    let collection = Episode.Collection.mock
    let store = TestStore(initialState: CategoriesFeature.State()) {
      CategoriesFeature()
    }
    
    await store.send(.collectionTapped(collection)) {
      $0.selectedCollection = CollectionDetailFeature.State(collection: collection)
    }
  }
}
