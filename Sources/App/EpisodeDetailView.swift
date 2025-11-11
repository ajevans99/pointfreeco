import AVKit
import ComposableArchitecture
import Models
import SwiftUI

public struct EpisodeDetailView: View {
  @Bindable public var store: StoreOf<EpisodeDetailFeature>
  @Environment(\.dismiss) var dismiss
  
  public init(store: StoreOf<EpisodeDetailFeature>) {
    self.store = store
  }
  
  public var body: some View {
    NavigationStack {
      ScrollView {
        VStack(alignment: .leading, spacing: 20) {
          // Video Player
          VideoPlayerView(episode: store.episode, isPlaying: store.isPlaying)
            .aspectRatio(16/9, contentMode: .fit)
            .frame(maxWidth: .infinity)
          
          VStack(alignment: .leading, spacing: 16) {
            Text("Episode \(store.episode.sequence.rawValue)")
              .font(.caption)
              .foregroundColor(.secondary)
            
            Text(store.episode.fullTitle)
              .font(.title2)
              .fontWeight(.bold)
            
            HStack {
              Label("\(store.episode.length.rawValue / 60) min", systemImage: "clock")
              Spacer()
              Text(store.episode.publishedAt, style: .date)
            }
            .font(.caption)
            .foregroundColor(.secondary)
            
            Divider()
            
            Text(store.episode.blurb)
              .font(.body)
            
            Button(action: {
              store.send(.playTapped)
            }) {
              HStack {
                Image(systemName: store.isPlaying ? "pause.fill" : "play.fill")
                Text(store.isPlaying ? "Pause" : "Play")
              }
              .frame(maxWidth: .infinity)
              .padding()
              .background(Color.accentColor)
              .foregroundColor(.white)
              .cornerRadius(12)
            }
          }
          .padding()
        }
      }
      .navigationTitle("Episode Detail")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .navigationBarTrailing) {
          Button("Done") {
            dismiss()
          }
        }
      }
    }
  }
}

struct VideoPlayerView: View {
  let episode: Episode
  let isPlaying: Bool
  
  var body: some View {
    ZStack {
      if let videoURL = URL(string: episode.trailerVideo.downloadUrls.hd1080) {
        VideoPlayer(player: AVPlayer(url: videoURL))
      } else {
        Rectangle()
          .fill(Color.gray.opacity(0.3))
          .overlay(
            VStack {
              Image(systemName: "video.slash")
                .font(.largeTitle)
              Text("Video unavailable")
                .font(.caption)
            }
            .foregroundColor(.secondary)
          )
      }
    }
  }
}

#Preview {
  EpisodeDetailView(
    store: Store(
      initialState: EpisodeDetailFeature.State(
        episode: .mock
      )
    ) {
      EpisodeDetailFeature()
    }
  )
}
