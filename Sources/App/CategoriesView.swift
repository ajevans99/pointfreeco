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
      ScrollView {
        if store.isLoading {
          ProgressView()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
          LazyVGrid(columns: [
            GridItem(.adaptive(minimum: 300, maximum: 500), spacing: 20)
          ], spacing: 20) {
            ForEach(store.collections, id: \.title) { collection in
              CollectionCard(collection: collection)
                .onTapGesture {
                  store.send(.collectionTapped(collection))
                }
            }
          }
          .padding()
        }
      }
      .navigationTitle("Categories")
      .task {
        store.send(.task)
      }
      .sheet(
        item: $store.scope(state: \.selectedCollection, action: \.selectedCollection)
      ) { store in
        CollectionDetailView(store: store)
      }
    }
  }
}

struct CollectionCard: View {
  let collection: Episode.Collection
  
  var body: some View {
    VStack(alignment: .leading, spacing: 12) {
      // Collection poster or placeholder
      if let posterURL = collection.posterURL,
         let url = URL(string: posterURL) {
        AsyncImage(url: url) { image in
          image
            .resizable()
            .aspectRatio(1, contentMode: .fill)
        } placeholder: {
          Rectangle()
            .fill(Color.gray.opacity(0.3))
            .aspectRatio(1, contentMode: .fill)
        }
        .clipShape(RoundedRectangle(cornerRadius: 12))
      } else {
        Rectangle()
          .fill(
            LinearGradient(
              colors: [Color.blue.opacity(0.6), Color.purple.opacity(0.6)],
              startPoint: .topLeading,
              endPoint: .bottomTrailing
            )
          )
          .aspectRatio(1, contentMode: .fill)
          .clipShape(RoundedRectangle(cornerRadius: 12))
          .overlay(
            Image(systemName: "square.grid.2x2")
              .font(.system(size: 48))
              .foregroundColor(.white.opacity(0.8))
          )
      }
      
      VStack(alignment: .leading, spacing: 8) {
        Text(collection.title)
          .font(.title3)
          .fontWeight(.semibold)
          .lineLimit(2)
        
        Text(collection.blurb)
          .font(.body)
          .foregroundColor(.secondary)
          .lineLimit(3)
        
        HStack {
          Label("\(collection.numberOfEpisodes) episodes", systemImage: "play.rectangle.fill")
          Spacer()
          Label("\(collection.length.rawValue / 60) min", systemImage: "clock")
        }
        .font(.caption)
        .foregroundColor(.secondary)
      }
      .padding(.horizontal, 4)
    }
    .background(Color(uiColor: .systemBackground))
    .cornerRadius(16)
    .shadow(radius: 4)
  }
}

#Preview {
  CategoriesView(
    store: Store(initialState: CategoriesFeature.State()) {
      CategoriesFeature()
    }
  )
}
