import ComposableArchitecture
import Foundation
import Models

@Reducer
public struct CategoriesFeature {
  @ObservableState
  public struct State: Equatable {
    public init() {}
  }
  
  public enum Action {
    case task
  }
  
  public init() {}
  
  public var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .task:
        // TODO: Implement collections API endpoint
        return .none
      }
    }
  }
}
