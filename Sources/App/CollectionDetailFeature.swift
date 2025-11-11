import ComposableArchitecture
import Foundation
import Models

@Reducer
public struct CollectionDetailFeature {
  @ObservableState
  public struct State: Equatable {
    public var collection: Episode.Collection
    @Presents public var selectedEpisode: EpisodeDetailFeature.State?
    
    public init(collection: Episode.Collection) {
      self.collection = collection
    }
  }
  
  public enum Action {
    case episodeTapped(Episode)
    case selectedEpisode(PresentationAction<EpisodeDetailFeature.Action>)
  }
  
  public init() {}
  
  public var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
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
