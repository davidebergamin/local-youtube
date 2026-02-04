import Foundation

@MainActor
final class AppState: ObservableObject {
    @Published var downloadQueue: [DownloadItem] = []
    @Published var localLibrary: [DownloadItem] = []

    private let libraryStore = LibraryStore()

    init() {
        loadLibrary()
    }

    func queueDownload(_ item: DownloadItem) {
        downloadQueue.append(item)
    }

    func completeDownload(_ item: DownloadItem) {
        downloadQueue.removeAll { $0.id == item.id }
        localLibrary.append(item)
        saveLibrary()
    }

    func removeFromLibrary(_ item: DownloadItem) {
        localLibrary.removeAll { $0.id == item.id }
        saveLibrary()
    }

    private func loadLibrary() {
        localLibrary = (try? libraryStore.loadLibrary()) ?? []
    }

    private func saveLibrary() {
        do {
            try libraryStore.saveLibrary(localLibrary)
        } catch {
            print("Failed to save library: \(error)")
        }
    }
}
