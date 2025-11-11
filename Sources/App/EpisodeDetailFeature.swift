import ComposableArchitecture
import Foundation
import Models

@Reducer
public struct EpisodeDetailFeature {
  @ObservableState
  public struct State: Equatable {
    public var episode: Episode
    public var isPlaying = false
    
    public init(episode: Episode) {
      self.episode = episode
    }
  }
  
  public enum Action {
    case playTapped
    case closeTapped
  }
  
  public init() {}
  
  public var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .playTapped:
        state.isPlaying.toggle()
        return .none
        
      case .closeTapped:
        return .none
      }
    }
  }
}
