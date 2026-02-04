import AVFoundation
import Foundation

final class LibraryStore: ObservableObject {
    enum SortOption: String, CaseIterable, Identifiable {
        case date = "Date"
        case title = "Title"

        var id: String { rawValue }
    }

    @Published private(set) var videos: [DownloadedVideo] = []
    @Published var sortOption: SortOption = .date
    @Published var groupByDate: Bool = true

    private let fileManager = FileManager.default
    private lazy var libraryURL: URL = {
        documentsDirectory().appendingPathComponent("library.json")
    }()

    init() {
        load()
        refreshMetadata()
    }

    var sortedVideos: [DownloadedVideo] {
        switch sortOption {
        case .date:
            return videos.sorted { $0.downloadDate > $1.downloadDate }
        case .title:
            return videos.sorted { $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending }
        }
    }

    var groupedVideos: [(String, [DownloadedVideo])] {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        let grouped = Dictionary(grouping: sortedVideos) { video in
            formatter.string(from: video.downloadDate)
        }
        return grouped.keys.sorted(by: >).map { key in
            (key, grouped[key] ?? [])
        }
    }

    func fileURL(for video: DownloadedVideo) -> URL {
        documentsDirectory().appendingPathComponent(video.fileName)
    }

    func delete(_ video: DownloadedVideo) {
        if let index = videos.firstIndex(of: video) {
            let url = fileURL(for: video)
            try? fileManager.removeItem(at: url)
            videos.remove(at: index)
            save()
        }
    }

    func rename(_ video: DownloadedVideo, to newTitle: String) {
        guard let index = videos.firstIndex(of: video) else { return }
        let url = fileURL(for: video)
        let newFileName = safeFileName(from: newTitle, originalFileName: video.fileName)
        let newURL = documentsDirectory().appendingPathComponent(newFileName)
        if url != newURL {
            try? fileManager.moveItem(at: url, to: newURL)
        }
        var updated = videos[index]
        updated.title = newTitle
        updated.fileName = newFileName
        videos[index] = updated
        save()
    }

    func updateFileName(_ video: DownloadedVideo, newFileName: String) {
        guard let index = videos.firstIndex(of: video) else { return }
        var updated = videos[index]
        updated.fileName = newFileName
        videos[index] = updated
        save()
    }

    func add(_ video: DownloadedVideo) {
        videos.append(video)
        save()
    }

    func refreshMetadata() {
        videos = videos.map { video in
            var updated = video
            let url = fileURL(for: video)
            if let attributes = try? fileManager.attributesOfItem(atPath: url.path) {
                updated.fileSizeBytes = attributes[.size] as? Int64
            }
            let asset = AVAsset(url: url)
            let durationSeconds = CMTimeGetSeconds(asset.duration)
            if durationSeconds.isFinite {
                updated.duration = durationSeconds
            }
            return updated
        }
        save()
    }

    private func documentsDirectory() -> URL {
        fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }

    private func safeFileName(from title: String, originalFileName: String) -> String {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let allowed = trimmed.isEmpty ? "video" : trimmed
        let sanitized = allowed.replacingOccurrences(of: "/", with: "-")
            .replacingOccurrences(of: ":", with: "-")
            .replacingOccurrences(of: "\\", with: "-")
            .replacingOccurrences(of: "?", with: "-")
            .replacingOccurrences(of: "*", with: "-")
            .replacingOccurrences(of: "\"", with: "-")
            .replacingOccurrences(of: "<", with: "-")
            .replacingOccurrences(of: ">", with: "-")
            .replacingOccurrences(of: "|", with: "-")
        let ext = URL(fileURLWithPath: originalFileName).pathExtension
        return ext.isEmpty ? sanitized : "\(sanitized).\(ext)"
    }

    private func load() {
        guard let data = try? Data(contentsOf: libraryURL) else {
            videos = []
            return
        }
        do {
            videos = try JSONDecoder().decode([DownloadedVideo].self, from: data)
        } catch {
            videos = []
        }
    }

    private func save() {
        do {
            let data = try JSONEncoder().encode(videos)
            try data.write(to: libraryURL, options: [.atomic])
        } catch {
            return
        }
    }
}
