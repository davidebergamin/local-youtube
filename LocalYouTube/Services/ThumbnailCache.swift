import AVFoundation
import UIKit

final class ThumbnailCache {
    static let shared = ThumbnailCache()

    private let cache = NSCache<NSString, UIImage>()
    private let fileManager = FileManager.default

    private lazy var cacheDirectory: URL = {
        let directory = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("thumbnails", isDirectory: true)
        if !fileManager.fileExists(atPath: directory.path) {
            try? fileManager.createDirectory(at: directory, withIntermediateDirectories: true)
        }
        return directory
    }()

    func thumbnail(for video: DownloadedVideo, fileURL: URL) async -> UIImage? {
        let key = NSString(string: video.id.uuidString)
        if let cached = cache.object(forKey: key) {
            return cached
        }
        let diskURL = cacheDirectory.appendingPathComponent("\(video.id.uuidString).png")
        if let data = try? Data(contentsOf: diskURL),
           let image = UIImage(data: data) {
            cache.setObject(image, forKey: key)
            return image
        }
        guard let image = generateThumbnail(for: fileURL) else {
            return nil
        }
        cache.setObject(image, forKey: key)
        if let data = image.pngData() {
            try? data.write(to: diskURL, options: [.atomic])
        }
        return image
    }

    private func generateThumbnail(for url: URL) -> UIImage? {
        let asset = AVAsset(url: url)
        let generator = AVAssetImageGenerator(asset: asset)
        generator.appliesPreferredTrackTransform = true
        let time = CMTime(seconds: 1, preferredTimescale: 600)
        if let cgImage = try? generator.copyCGImage(at: time, actualTime: nil) {
            return UIImage(cgImage: cgImage)
        }
        return nil
    }
}
