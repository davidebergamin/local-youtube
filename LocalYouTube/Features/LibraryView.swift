import SwiftUI

struct LibraryView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        List {
            if appState.localLibrary.isEmpty {
                ContentUnavailableView("No Downloads", systemImage: "tray")
            } else {
                ForEach(appState.localLibrary) { item in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(item.title)
                            .font(.headline)
                        Text(item.author)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                .onDelete(perform: deleteItems)
            }
        }
        .navigationTitle("Library")
        .toolbar {
            EditButton()
        }
    }

    private func deleteItems(offsets: IndexSet) {
        for index in offsets {
            let item = appState.localLibrary[index]
            appState.removeFromLibrary(item)
        }
    }
}

#Preview {
    NavigationStack {
        LibraryView()
            .environmentObject(AppState())
    }
}
