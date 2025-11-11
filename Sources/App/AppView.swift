import ComposableArchitecture
import SwiftUI

public struct AppView: View {
  @Bindable public var store: StoreOf<AppFeature>
  
  public init(store: StoreOf<AppFeature>) {
    self.store = store
  }
  
  public var body: some View {
    TabView(selection: $store.selectedTab.sending(\.selectedTabChanged)) {
      EpisodesView(
        store: store.scope(state: \.episodes, action: \.episodes)
      )
      .tabItem {
        Label("Episodes", systemImage: "play.rectangle.fill")
      }
      .tag(AppFeature.State.Tab.episodes)
      
      CategoriesView(
        store: store.scope(state: \.categories, action: \.categories)
      )
      .tabItem {
        Label("Categories", systemImage: "square.grid.2x2.fill")
      }
      .tag(AppFeature.State.Tab.categories)
      
      AuthenticationView(
        store: store.scope(state: \.authentication, action: \.authentication)
      )
      .tabItem {
        Label("Account", systemImage: "person.circle.fill")
      }
      .tag(AppFeature.State.Tab.account)
    }
  }
}

#Preview {
  AppView(
    store: Store(initialState: AppFeature.State()) {
      AppFeature()
    }
  )
}
