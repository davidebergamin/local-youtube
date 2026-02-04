import SwiftUI

@main
struct LocalYouTubeApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            DownloadView(
                viewModel: DownloadViewModel(
                    downloadService: YouTubeDownloadService(),
                    repository: DownloadRepository(context: persistenceController.container.viewContext)
                )
            )
            .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
