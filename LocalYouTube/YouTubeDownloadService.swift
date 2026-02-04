import Foundation

struct VideoStream: Identifiable, Hashable {
    let id = UUID()
    let resolution: String
    let qualityLabel: String
    let sizeInBytes: Int64
    let downloadURL: URL

    var displayName: String {
        "\(qualityLabel) • \(resolution)"
    }

    var sizeDescription: String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useMB, .useGB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: sizeInBytes)
    }
}

struct DownloadRecord: Identifiable, Hashable {
    let id: UUID
    let title: String
    let thumbnailURL: String?
    let duration: Double
    let localFilePath: String
    let resolution: String
    let createdAt: Date
}

protocol StreamResolving {
    func resolveStreams(for url: URL) async throws -> [VideoStream]
}

protocol Downloading {
    func download(stream: VideoStream, sourceURL: URL, progressHandler: @escaping (Double) -> Void) async throws -> DownloadRecord
}

final class YouTubeDownloadService: StreamResolving, Downloading {
    private let resolver: StreamResolving
    private let metadataProvider: VideoMetadataProviding

    init(
        resolver: StreamResolving = BackendStreamResolver(),
        metadataProvider: VideoMetadataProviding = BackendMetadataProvider()
    ) {
        self.resolver = resolver
        self.metadataProvider = metadataProvider
    }

    func resolveStreams(for url: URL) async throws -> [VideoStream] {
        try await resolver.resolveStreams(for: url)
    }

    func download(
        stream: VideoStream,
        sourceURL: URL,
        progressHandler: @escaping (Double) -> Void
    ) async throws -> DownloadRecord {
        let metadata = try await metadataProvider.fetchMetadata(for: sourceURL)
        let localURL = try await downloadStream(stream, progressHandler: progressHandler)
        return DownloadRecord(
            id: UUID(),
            title: metadata.title,
            thumbnailURL: metadata.thumbnailURL,
            duration: metadata.duration,
            localFilePath: localURL.path,
            resolution: stream.resolution,
            createdAt: Date()
        )
    }

    private func downloadStream(_ stream: VideoStream, progressHandler: @escaping (Double) -> Void) async throws -> URL {
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        guard let documentsURL else {
            throw DownloadError.missingDocumentsDirectory
        }

        progressHandler(0)
        let (downloadURL, response) = try await URLSession.shared.download(from: stream.downloadURL)
        progressHandler(1)

        guard let httpResponse = response as? HTTPURLResponse,
              (200..<300).contains(httpResponse.statusCode) else {
            throw DownloadError.invalidResponse
        }

        let sanitizedName = "download-\(UUID().uuidString).mp4"
        let destinationURL = documentsURL.appendingPathComponent(sanitizedName)
        try? FileManager.default.removeItem(at: destinationURL)
        try FileManager.default.moveItem(at: downloadURL, to: destinationURL)
        return destinationURL
    }
}

enum DownloadError: LocalizedError {
    case missingDocumentsDirectory
    case invalidResponse

    var errorDescription: String? {
        switch self {
        case .missingDocumentsDirectory:
            return "Unable to access the documents directory."
        case .invalidResponse:
            return "The download service returned an invalid response."
        }
    }
}
