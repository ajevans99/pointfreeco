import ComposableArchitecture
import Models
import SwiftUI

public struct CollectionDetailView: View {
  @Bindable public var store: StoreOf<CollectionDetailFeature>
  @Environment(\.dismiss) var dismiss
  
  public init(store: StoreOf<CollectionDetailFeature>) {
    self.store = store
  }
  
  public var body: some View {
    NavigationStack {
      ScrollView {
        VStack(alignment: .leading, spacing: 20) {
          // Collection header
          VStack(alignment: .leading, spacing: 16) {
            Text(store.collection.title)
              .font(.largeTitle)
              .fontWeight(.bold)
            
            Text(store.collection.blurb)
              .font(.body)
              .foregroundColor(.secondary)
            
            HStack {
              Label("\(store.collection.numberOfEpisodes) episodes", systemImage: "play.rectangle.fill")
              Spacer()
              Label("\(store.collection.length.rawValue / 60) min", systemImage: "clock")
            }
            .font(.caption)
            .foregroundColor(.secondary)
          }
          .padding()
          
          Divider()
          
          // Sections
          ForEach(store.collection.sections, id: \.title) { section in
            VStack(alignment: .leading, spacing: 12) {
              Text(section.title)
                .font(.title2)
                .fontWeight(.semibold)
                .padding(.horizontal)
              
              Text(section.blurb)
                .font(.body)
                .foregroundColor(.secondary)
                .padding(.horizontal)
              
              // Episodes in section
              ForEach(section.coreLessons, id: \.title) { lesson in
                if case let .episode(episode) = lesson {
                  Button(action: {
                    store.send(.episodeTapped(episode))
                  }) {
                    HStack(spacing: 12) {
                      AsyncImage(url: URL(string: episode.image)) { image in
                        image
                          .resizable()
                          .aspectRatio(16/9, contentMode: .fill)
                      } placeholder: {
                        Rectangle()
                          .fill(Color.gray.opacity(0.3))
                          .aspectRatio(16/9, contentMode: .fill)
                      }
                      .frame(width: 120)
                      .clipShape(RoundedRectangle(cornerRadius: 8))
                      
                      VStack(alignment: .leading, spacing: 4) {
                        Text("Episode \(episode.sequence.rawValue)")
                          .font(.caption)
                          .foregroundColor(.secondary)
                        
                        Text(episode.fullTitle)
                          .font(.body)
                          .fontWeight(.medium)
                          .lineLimit(2)
                        
                        Label("\(episode.length.rawValue / 60) min", systemImage: "clock")
                          .font(.caption)
                          .foregroundColor(.secondary)
                      }
                      
                      Spacer()
                      
                      Image(systemName: "chevron.right")
                        .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color(uiColor: .secondarySystemBackground))
                    .cornerRadius(12)
                  }
                  .buttonStyle(.plain)
                  .padding(.horizontal)
                }
              }
            }
          }
        }
        .padding(.vertical)
      }
      .navigationTitle("Collection")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .navigationBarTrailing) {
          Button("Done") {
            dismiss()
          }
        }
      }
      .sheet(
        item: $store.scope(state: \.selectedEpisode, action: \.selectedEpisode)
      ) { store in
        EpisodeDetailView(store: store)
      }
    }
  }
}

#Preview {
  CollectionDetailView(
    store: Store(
      initialState: CollectionDetailFeature.State(
        collection: .mock
      )
    ) {
      CollectionDetailFeature()
    }
  )
}
