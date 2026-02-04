import Foundation

struct DownloadService {
    func enqueue(_ item: DownloadItem, in appState: AppState) {
        appState.queueDownload(item)
    }
}
