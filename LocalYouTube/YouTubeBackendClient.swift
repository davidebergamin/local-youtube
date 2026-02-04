import Foundation

struct StreamResolutionResponse: Decodable {
    let streams: [StreamResponse]
}

struct StreamResponse: Decodable {
    let resolution: String
    let qualityLabel: String
    let sizeInBytes: Int64
    let downloadURL: URL
}

struct VideoMetadata: Decodable {
    let title: String
    let thumbnailURL: String?
    let duration: Double
}

protocol VideoMetadataProviding {
    func fetchMetadata(for url: URL) async throws -> VideoMetadata
}

final class BackendStreamResolver: StreamResolving {
    private let client: YouTubeBackendClient

    init(client: YouTubeBackendClient = YouTubeBackendClient()) {
        self.client = client
    }

    func resolveStreams(for url: URL) async throws -> [VideoStream] {
        let response: StreamResolutionResponse = try await client.send(
            endpoint: .resolveStreams,
            body: ["url": url.absoluteString]
        )

        let streams = response.streams.map {
            VideoStream(
                resolution: $0.resolution,
                qualityLabel: $0.qualityLabel,
                sizeInBytes: $0.sizeInBytes,
                downloadURL: $0.downloadURL
            )
        }
        if streams.isEmpty {
            throw BackendError.noStreams
        }
        return streams
    }
}

final class BackendMetadataProvider: VideoMetadataProviding {
    private let client: YouTubeBackendClient

    init(client: YouTubeBackendClient = YouTubeBackendClient()) {
        self.client = client
    }

    func fetchMetadata(for url: URL) async throws -> VideoMetadata {
        try await client.send(endpoint: .metadata, body: ["url": url.absoluteString])
    }
}

final class YouTubeBackendClient {
    private let baseURL: URL
    private let session: URLSession

    init(baseURL: URL = URL(string: "https://example-backend.local")!, session: URLSession = .shared) {
        self.baseURL = baseURL
        self.session = session
    }

    func send<T: Decodable>(endpoint: Endpoint, body: [String: String]) async throws -> T {
        var request = URLRequest(url: baseURL.appendingPathComponent(endpoint.path))
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse,
              (200..<300).contains(httpResponse.statusCode) else {
            throw BackendError.invalidResponse
        }

        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            throw BackendError.decodingFailed
        }
    }

    enum Endpoint {
        case resolveStreams
        case metadata

        var path: String {
            switch self {
            case .resolveStreams:
                return "/resolve"
            case .metadata:
                return "/metadata"
            }
        }
    }
}

enum BackendError: LocalizedError {
    case invalidResponse
    case decodingFailed
    case noStreams

    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "The backend service returned an invalid response."
        case .decodingFailed:
            return "Unable to decode the backend response."
        case .noStreams:
            return "No downloadable streams were available for this URL."
        }
    }
}
