import SwiftUI

struct DownloadsView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        List {
            if appState.downloadQueue.isEmpty {
                ContentUnavailableView("Nothing queued", systemImage: "arrow.down.circle")
            } else {
                ForEach(appState.downloadQueue) { item in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(item.title)
                            .font(.headline)
                        Text("Queued from \(item.sourceURL.host ?? "unknown")")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .navigationTitle("Downloads")
    }
}

#Preview {
    NavigationStack {
        DownloadsView()
            .environmentObject(AppState())
    }
}
