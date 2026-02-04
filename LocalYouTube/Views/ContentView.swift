import SwiftUI

struct ContentView: View {
    @StateObject private var libraryStore = LibraryStore()

    var body: some View {
        LibraryView()
            .environmentObject(libraryStore)
    }
}
