import ComposableArchitecture
import Models
import XCTest

@testable import App

@MainActor
final class EpisodesFeatureTests: XCTestCase {
  func testLoadEpisodes() async {
    let mockEpisodes: [ApiClient.EpisodeListItem] = [
      ApiClient.EpisodeListItem(
        blurb: "Test episode",
        id: Episode.ID(rawValue: 1),
        image: "https://example.com/image.jpg",
        length: 1800,
        publishedAt: Date(),
        sequence: Episode.Sequence(rawValue: 1),
        subscriberOnly: false,
        title: "Episode 1"
      )
    ]
    
    let store = TestStore(initialState: EpisodesFeature.State()) {
      EpisodesFeature()
    } withDependencies: {
      $0.apiClient.fetchEpisodes = { mockEpisodes }
    }
    
    await store.send(.task) {
      $0.isLoading = true
      $0.errorMessage = nil
    }
    
    await store.receive(\.episodesLoaded) {
      $0.episodes = mockEpisodes
      $0.isLoading = false
    }
  }
  
  func testEpisodeSelection() async {
    let episodeId = Episode.ID(rawValue: 1)
    let store = TestStore(initialState: EpisodesFeature.State()) {
      EpisodesFeature()
    }
    
    await store.send(.episodeTapped(episodeId)) {
      $0.selectedEpisode = EpisodeDetailFeature.State(episodeId: episodeId)
    }
  }
  
  func testLoadEpisodesFailed() async {
    struct TestError: Error {}
    
    let store = TestStore(initialState: EpisodesFeature.State()) {
      EpisodesFeature()
    } withDependencies: {
      $0.apiClient.fetchEpisodes = { throw TestError() }
    }
    
    await store.send(.task) {
      $0.isLoading = true
      $0.errorMessage = nil
    }
    
    await store.receive(\.episodesFailed) {
      $0.isLoading = false
      $0.errorMessage = "The operation couldn't be completed. (AppTests.EpisodesFeatureTests.(unknown context at $10204c698).(unknown context at $10204c6b0).TestError error 1.)"
    }
  }
}
