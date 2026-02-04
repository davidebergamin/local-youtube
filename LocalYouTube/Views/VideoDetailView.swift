import AVFoundation
import SwiftUI

struct VideoDetailView: View {
    @EnvironmentObject var libraryStore: LibraryStore

    let video: DownloadedVideo

    @State private var metadata: VideoMetadata?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                LocalPlayerView(url: libraryStore.fileURL(for: video))
                    .frame(height: 220)
                    .cornerRadius(12)

                VStack(alignment: .leading, spacing: 8) {
                    Text(video.title)
                        .font(.title2)
                        .fontWeight(.semibold)

                    if let metadata {
                        MetadataRow(label: "Downloaded", value: metadata.downloadedText)
                        MetadataRow(label: "Duration", value: metadata.durationText)
                        MetadataRow(label: "File Size", value: metadata.fileSizeText)
                        MetadataRow(label: "File Name", value: metadata.fileName)
                    }
                }
                .padding(.horizontal)

                Text("Playback is fully local and works without network access, including Airplane Mode.")
                    .font(.footnote)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
            }
            .padding(.top)
        }
        .navigationTitle("Details")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            metadata = VideoMetadata(video: video, fileURL: libraryStore.fileURL(for: video))
        }
    }
}

private struct MetadataRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .font(.subheadline)
        }
    }
}

private struct VideoMetadata {
    let downloadedText: String
    let durationText: String
    let fileSizeText: String
    let fileName: String

    init(video: DownloadedVideo, fileURL: URL) {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        downloadedText = formatter.string(from: video.downloadDate)

        let durationValue: TimeInterval
        if let duration = video.duration {
            durationValue = duration
        } else {
            let asset = AVAsset(url: fileURL)
            durationValue = CMTimeGetSeconds(asset.duration)
        }

        if durationValue.isFinite {
            let minutes = Int(durationValue) / 60
            let seconds = Int(durationValue) % 60
            durationText = String(format: "%d:%02d", minutes, seconds)
        } else {
            durationText = "Unknown"
        }

        let bytes: Int64
        if let size = video.fileSizeBytes {
            bytes = size
        } else if let attributes = try? FileManager.default.attributesOfItem(atPath: fileURL.path),
                  let size = attributes[.size] as? Int64 {
            bytes = size
        } else {
            bytes = 0
        }

        let formatterBytes = ByteCountFormatter()
        formatterBytes.allowedUnits = [.useMB, .useGB]
        formatterBytes.countStyle = .file
        fileSizeText = bytes > 0 ? formatterBytes.string(fromByteCount: bytes) : "Unknown"

        fileName = fileURL.lastPathComponent
    }
}
