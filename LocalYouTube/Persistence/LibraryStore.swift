import Foundation

struct LibraryStore {
    private let fileManager = FileManager.default

    private var libraryURL: URL {
        let documents = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return documents.appendingPathComponent("library.json")
    }

    func loadLibrary() throws -> [DownloadItem] {
        guard fileManager.fileExists(atPath: libraryURL.path) else {
            return []
        }

        let data = try Data(contentsOf: libraryURL)
        return try JSONDecoder().decode([DownloadItem].self, from: data)
    }

    func saveLibrary(_ items: [DownloadItem]) throws {
        let data = try JSONEncoder().encode(items)
        try data.write(to: libraryURL, options: [.atomic])
    }
}
