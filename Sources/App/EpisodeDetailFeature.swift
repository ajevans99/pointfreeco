import ComposableArchitecture
import Foundation
import Models

@Reducer
public struct EpisodeDetailFeature {
  @ObservableState
  public struct State: Equatable {
    public var episodeId: Episode.ID
    public var episode: ApiClient.EpisodeDetail?
    public var isLoading = false
    public var isPlaying = false
    public var errorMessage: String?
    
    public init(episodeId: Episode.ID) {
      self.episodeId = episodeId
    }
  }
  
  public enum Action {
    case task
    case episodeLoaded(ApiClient.EpisodeDetail)
    case episodeFailed(Error)
    case playTapped
    case closeTapped
  }
  
  @Dependency(\.apiClient) var apiClient
  
  public init() {}
  
  public var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .task:
        state.isLoading = true
        state.errorMessage = nil
        return .run { [episodeId = state.episodeId] send in
          do {
            let episode = try await apiClient.fetchEpisode(episodeId)
            await send(.episodeLoaded(episode))
          } catch {
            await send(.episodeFailed(error))
          }
        }
        
      case let .episodeLoaded(episode):
        state.episode = episode
        state.isLoading = false
        return .none
        
      case let .episodeFailed(error):
        state.isLoading = false
        state.errorMessage = error.localizedDescription
        return .none
        
      case .playTapped:
        state.isPlaying.toggle()
        return .none
        
      case .closeTapped:
        return .none
      }
    }
  }
}
