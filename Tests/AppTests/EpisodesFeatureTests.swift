import ComposableArchitecture
import Models
import XCTest

@testable import App

@MainActor
final class EpisodesFeatureTests: XCTestCase {
  func testLoadEpisodes() async {
    let store = TestStore(initialState: EpisodesFeature.State()) {
      EpisodesFeature()
    }
    
    await store.send(.task) {
      $0.isLoading = true
    }
    
    await store.receive(\.episodesLoaded) {
      $0.episodes = Episode.all
      $0.isLoading = false
    }
  }
  
  func testEpisodeSelection() async {
    let episode = Episode.mock
    let store = TestStore(initialState: EpisodesFeature.State()) {
      EpisodesFeature()
    }
    
    await store.send(.episodeTapped(episode)) {
      $0.selectedEpisode = EpisodeDetailFeature.State(episode: episode)
    }
  }
}
