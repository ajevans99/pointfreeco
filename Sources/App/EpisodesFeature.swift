import ComposableArchitecture
import Foundation
import Models
import Transcripts

@Reducer
public struct EpisodesFeature {
  @ObservableState
  public struct State: Equatable {
    public var episodes: [Episode] = []
    public var isLoading = false
    @Presents public var selectedEpisode: EpisodeDetailFeature.State?
    
    public init() {}
  }
  
  public enum Action {
    case task
    case episodesLoaded([Episode])
    case episodeTapped(Episode)
    case selectedEpisode(PresentationAction<EpisodeDetailFeature.Action>)
  }
  
  @Dependency(\.collections) var collections
  
  public init() {}
  
  public var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .task:
        state.isLoading = true
        return .run { send in
          let episodes = Episode.all
          await send(.episodesLoaded(episodes))
        }
        
      case let .episodesLoaded(episodes):
        state.episodes = episodes
        state.isLoading = false
        return .none
        
      case let .episodeTapped(episode):
        state.selectedEpisode = EpisodeDetailFeature.State(episode: episode)
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
