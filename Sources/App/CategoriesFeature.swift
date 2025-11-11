import ComposableArchitecture
import Foundation
import Models
import Transcripts

@Reducer
public struct CategoriesFeature {
  @ObservableState
  public struct State: Equatable {
    public var collections: [Episode.Collection] = []
    public var isLoading = false
    @Presents public var selectedCollection: CollectionDetailFeature.State?
    
    public init() {}
  }
  
  public enum Action {
    case task
    case collectionsLoaded([Episode.Collection])
    case collectionTapped(Episode.Collection)
    case selectedCollection(PresentationAction<CollectionDetailFeature.Action>)
  }
  
  @Dependency(\.collections) var collections
  
  public init() {}
  
  public var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .task:
        state.isLoading = true
        return .run { send in
          let collections = Episode.Collection.all
          await send(.collectionsLoaded(collections))
        }
        
      case let .collectionsLoaded(collections):
        state.collections = collections
        state.isLoading = false
        return .none
        
      case let .collectionTapped(collection):
        state.selectedCollection = CollectionDetailFeature.State(collection: collection)
        return .none
        
      case .selectedCollection:
        return .none
      }
    }
    .ifLet(\.$selectedCollection, action: \.selectedCollection) {
      CollectionDetailFeature()
    }
  }
}
