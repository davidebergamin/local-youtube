import Foundation

struct DownloadItem: Identifiable, Codable, Equatable {
    let id: UUID
    var title: String
    var author: String
    var sourceURL: URL
    var localFilename: String?

    init(id: UUID = UUID(), title: String, author: String, sourceURL: URL, localFilename: String? = nil) {
        self.id = id
        self.title = title
        self.author = author
        self.sourceURL = sourceURL
        self.localFilename = localFilename
    }
}
