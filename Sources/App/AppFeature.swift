import ComposableArchitecture
import Foundation
import Models

@Reducer
public struct AppFeature {
  @ObservableState
  public struct State: Equatable {
    public var selectedTab: Tab = .episodes
    public var episodes = EpisodesFeature.State()
    public var categories = CategoriesFeature.State()
    public var authentication = AuthenticationFeature.State()
    
    public init() {}
    
    public enum Tab: Equatable {
      case episodes
      case categories
    }
  }
  
  public enum Action {
    case selectedTabChanged(State.Tab)
    case episodes(EpisodesFeature.Action)
    case categories(CategoriesFeature.Action)
    case authentication(AuthenticationFeature.Action)
  }
  
  public init() {}
  
  public var body: some ReducerOf<Self> {
    Scope(state: \.episodes, action: \.episodes) {
      EpisodesFeature()
    }
    Scope(state: \.categories, action: \.categories) {
      CategoriesFeature()
    }
    Scope(state: \.authentication, action: \.authentication) {
      AuthenticationFeature()
    }
    Reduce { state, action in
      switch action {
      case let .selectedTabChanged(tab):
        state.selectedTab = tab
        return .none
        
      case .episodes:
        return .none
        
      case .categories:
        return .none
        
      case .authentication:
        return .none
      }
    }
  }
}
