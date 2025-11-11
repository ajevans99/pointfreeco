import ComposableArchitecture
import Foundation
import Models

@DependencyClient
public struct ApiClient {
  public var fetchEpisodes: @Sendable () async throws -> [EpisodeListItem]
  public var fetchEpisode: @Sendable (Episode.ID) async throws -> EpisodeDetail
  
  public struct EpisodeListItem: Codable, Equatable, Identifiable {
    public var blurb: String
    public var id: Episode.ID
    public var image: String
    public var length: Seconds<Int>
    public var publishedAt: Date
    public var sequence: Episode.Sequence
    public var subscriberOnly: Bool
    public var title: String
  }
  
  public struct EpisodeDetail: Codable, Equatable {
    public var blurb: String
    public var codeSampleDirectory: String?
    public var id: Episode.ID
    public var image: String
    public var length: Seconds<Int>
    public var previousEpisodesInCollection: [EpisodeListItem]
    public var publishedAt: Date
    public var references: [Episode.Reference]
    public var sequence: Episode.Sequence
    public var subscriberOnly: Bool
    public var title: String
    public var video: Episode.Video
  }
}

extension ApiClient: DependencyKey {
  public static let liveValue: Self = {
    @Dependency(\.siteRouter) var siteRouter
    
    return Self(
      fetchEpisodes: {
        let urlString = siteRouter.url(for: .api(.episodes))
        guard let url = URL(string: urlString) else {
          throw URLError(.badURL)
        }
        let (data, _) = try await URLSession.shared.data(from: url)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode([EpisodeListItem].self, from: data)
      },
      fetchEpisode: { id in
        let urlString = siteRouter.url(for: .api(.episode(id)))
        guard let url = URL(string: urlString) else {
          throw URLError(.badURL)
        }
        let (data, _) = try await URLSession.shared.data(from: url)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(EpisodeDetail.self, from: data)
      }
    )
  }()
  
  public static let testValue = Self()
}

extension DependencyValues {
  public var apiClient: ApiClient {
    get { self[ApiClient.self] }
    set { self[ApiClient.self] = newValue }
  }
}
