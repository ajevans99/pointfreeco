import ComposableArchitecture
import Foundation
import Models

@Reducer
public struct EpisodesFeature {
  @ObservableState
  public struct State: Equatable {
    public var episodes: [ApiClient.EpisodeListItem] = []
    public var isLoading = false
    public var errorMessage: String?
    @Presents public var selectedEpisode: EpisodeDetailFeature.State?
    
    public init() {}
  }
  
  public enum Action {
    case task
    case episodesLoaded([ApiClient.EpisodeListItem])
    case episodesFailed(Error)
    case episodeTapped(Episode.ID)
    case selectedEpisode(PresentationAction<EpisodeDetailFeature.Action>)
  }
  
  @Dependency(\.apiClient) var apiClient
  
  public init() {}
  
  public var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .task:
        state.isLoading = true
        state.errorMessage = nil
        return .run { send in
          do {
            let episodes = try await apiClient.fetchEpisodes()
            await send(.episodesLoaded(episodes))
          } catch {
            await send(.episodesFailed(error))
          }
        }
        
      case let .episodesLoaded(episodes):
        state.episodes = episodes
        state.isLoading = false
        return .none
        
      case let .episodesFailed(error):
        state.isLoading = false
        state.errorMessage = error.localizedDescription
        return .none
        
      case let .episodeTapped(id):
        state.selectedEpisode = EpisodeDetailFeature.State(episodeId: id)
        return .none
        
      case .selectedEpisode:
        return .none
      }
    }
    .ifLet(\.$selectedEpisode, action: \.selectedEpisode) {
      EpisodeDetailFeature()
    }
  }
}
