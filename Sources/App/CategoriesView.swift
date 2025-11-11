import ComposableArchitecture
import Models
import SwiftUI

public struct CategoriesView: View {
  @Bindable public var store: StoreOf<CategoriesFeature>
  
  public init(store: StoreOf<CategoriesFeature>) {
    self.store = store
  }
  
  public var body: some View {
    NavigationStack {
      VStack(spacing: 20) {
        Image(systemName: "square.grid.2x2")
          .font(.system(size: 64))
          .foregroundColor(.secondary)
        
        Text("Categories Coming Soon")
          .font(.title2)
          .fontWeight(.semibold)
        
        Text("Collections and categories will be available once the API endpoint is implemented.")
          .font(.body)
          .foregroundColor(.secondary)
          .multilineTextAlignment(.center)
          .padding(.horizontal)
      }
      .frame(maxWidth: .infinity, maxHeight: .infinity)
      .navigationTitle("Categories")
      .task {
        store.send(.task)
      }
    }
  }
}

#Preview {
  CategoriesView(
    store: Store(initialState: CategoriesFeature.State()) {
      CategoriesFeature()
    }
  )
}
