import ComposableArchitecture
import Models
import SwiftUI

public struct EpisodesView: View {
  @Bindable public var store: StoreOf<EpisodesFeature>
  
  public init(store: StoreOf<EpisodesFeature>) {
    self.store = store
  }
  
  public var body: some View {
    NavigationStack {
      ScrollView {
        if store.isLoading {
          ProgressView()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
          LazyVStack(spacing: 20) {
            ForEach(store.episodes) { episode in
              EpisodeCard(episode: episode)
                .onTapGesture {
                  store.send(.episodeTapped(episode))
                }
            }
          }
          .padding()
        }
      }
      .navigationTitle("Episodes")
      .task {
        store.send(.task)
      }
      .sheet(
        item: $store.scope(state: \.selectedEpisode, action: \.selectedEpisode)
      ) { store in
        EpisodeDetailView(store: store)
      }
    }
  }
}

struct EpisodeCard: View {
  let episode: Episode
  
  var body: some View {
    VStack(alignment: .leading, spacing: 12) {
      // Episode image
      AsyncImage(url: URL(string: episode.image)) { image in
        image
          .resizable()
          .aspectRatio(16/9, contentMode: .fill)
      } placeholder: {
        Rectangle()
          .fill(Color.gray.opacity(0.3))
          .aspectRatio(16/9, contentMode: .fill)
      }
      .clipShape(RoundedRectangle(cornerRadius: 12))
      
      VStack(alignment: .leading, spacing: 8) {
        Text("Episode \(episode.sequence.rawValue)")
          .font(.caption)
          .foregroundColor(.secondary)
        
        Text(episode.fullTitle)
          .font(.title3)
          .fontWeight(.semibold)
          .lineLimit(2)
        
        Text(episode.blurb)
          .font(.body)
          .foregroundColor(.secondary)
          .lineLimit(3)
        
        HStack {
          Label("\(episode.length.rawValue / 60) min", systemImage: "clock")
          Spacer()
          Text(episode.publishedAt, style: .date)
        }
        .font(.caption)
        .foregroundColor(.secondary)
      }
      .padding(.horizontal, 4)
    }
    .background(Color(.systemBackground))
    .cornerRadius(16)
    .shadow(radius: 4)
  }
}

#Preview {
  EpisodesView(
    store: Store(initialState: EpisodesFeature.State()) {
      EpisodesFeature()
    }
  )
}
