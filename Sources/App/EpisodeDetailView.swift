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
      Group {
        if store.isLoading {
          ProgressView()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if let errorMessage = store.errorMessage {
          VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
              .font(.largeTitle)
              .foregroundColor(.secondary)
            Text("Failed to load episode")
              .font(.headline)
            Text(errorMessage)
              .font(.caption)
              .foregroundColor(.secondary)
            Button("Retry") {
              store.send(.task)
            }
          }
        } else if let episode = store.episode {
          ScrollView {
            VStack(alignment: .leading, spacing: 20) {
              // Video Player
              VideoPlayerView(video: episode.video, isPlaying: store.isPlaying)
                .aspectRatio(16/9, contentMode: .fit)
                .frame(maxWidth: .infinity)
              
              VStack(alignment: .leading, spacing: 16) {
                Text("Episode \(episode.sequence.rawValue)")
                  .font(.caption)
                  .foregroundColor(.secondary)
                
                Text(episode.title)
                  .font(.title2)
                  .fontWeight(.bold)
                
                HStack {
                  Label("\(episode.length.rawValue / 60) min", systemImage: "clock")
                  Spacer()
                  Text(episode.publishedAt, style: .date)
                }
                .font(.caption)
                .foregroundColor(.secondary)
                
                Divider()
                
                Text(episode.blurb)
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
      .task {
        store.send(.task)
      }
    }
  }
}

struct VideoPlayerView: View {
  let video: Episode.Video
  let isPlaying: Bool
  
  var body: some View {
    ZStack {
      // Extract video URL based on the download URL type
      if case let .s3(hd1080, _, _) = video.downloadUrl,
         let videoURL = URL(string: "https://pointfreeco-episodes-processed.s3.amazonaws.com/\(hd1080).mp4") {
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
        episodeId: Episode.ID(rawValue: 1)
      )
    ) {
      EpisodeDetailFeature()
    }
  )
}
