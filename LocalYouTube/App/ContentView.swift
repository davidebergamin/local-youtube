import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack {
            List {
                NavigationLink("Library") {
                    LibraryView()
                }
                NavigationLink("Downloads") {
                    DownloadsView()
                }
            }
            .navigationTitle("Local YouTube")
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AppState())
}
