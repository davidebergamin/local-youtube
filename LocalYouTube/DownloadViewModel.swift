import Foundation
import SwiftUI

@MainActor
final class DownloadViewModel: ObservableObject {
    @Published var videoURL: String = ""
    @Published var availableStreams: [VideoStream] = []
    @Published var selectedStream: VideoStream?
    @Published var isResolving: Bool = false
    @Published var isDownloading: Bool = false
    @Published var downloadProgress: Double?
    @Published var errorMessage: String?
    @Published var recentDownloads: [DownloadRecord] = []

    private let downloadService: YouTubeDownloadService
    private let repository: DownloadRepository

    init(downloadService: YouTubeDownloadService, repository: DownloadRepository) {
        self.downloadService = downloadService
        self.repository = repository
    }

    func resolveStreams() {
        Task {
            guard let url = URL(string: videoURL.trimmingCharacters(in: .whitespacesAndNewlines)) else {
                errorMessage = "Please enter a valid URL."
                return
            }

            isResolving = true
            errorMessage = nil
            do {
                let streams = try await downloadService.resolveStreams(for: url)
                availableStreams = streams
                selectedStream = streams.first
            } catch {
                errorMessage = error.localizedDescription
            }
            isResolving = false
        }
    }

    func downloadSelectedStream() {
        Task {
            guard let stream = selectedStream,
                  let url = URL(string: videoURL.trimmingCharacters(in: .whitespacesAndNewlines)) else {
                errorMessage = "Select a quality option first."
                return
            }

            isDownloading = true
            errorMessage = nil
            downloadProgress = 0

            do {
                let result = try await downloadService.download(stream: stream, from: url) { [weak self] progress in
                    self?.downloadProgress = progress
                }
                repository.save(record: result)
                loadRecentDownloads()
            } catch {
                errorMessage = error.localizedDescription
            }

            isDownloading = false
            downloadProgress = nil
        }
    }

    func loadRecentDownloads() {
        recentDownloads = repository.fetchAll()
    }
}
