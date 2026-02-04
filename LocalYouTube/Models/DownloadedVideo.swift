import Foundation

struct DownloadedVideo: Identifiable, Codable, Hashable {
    let id: UUID
    var title: String
    var fileName: String
    var downloadDate: Date
    var duration: TimeInterval?
    var fileSizeBytes: Int64?

    init(
        id: UUID = UUID(),
        title: String,
        fileName: String,
        downloadDate: Date = Date(),
        duration: TimeInterval? = nil,
        fileSizeBytes: Int64? = nil
    ) {
        self.id = id
        self.title = title
        self.fileName = fileName
        self.downloadDate = downloadDate
        self.duration = duration
        self.fileSizeBytes = fileSizeBytes
    }
}
