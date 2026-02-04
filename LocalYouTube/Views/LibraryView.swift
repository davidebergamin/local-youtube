import SwiftUI

struct LibraryView: View {
    @EnvironmentObject var libraryStore: LibraryStore

    @State private var renameTarget: DownloadedVideo?

    var body: some View {
        NavigationView {
            VStack(spacing: 12) {
                headerControls
                if libraryStore.groupByDate {
                    groupedList
                } else {
                    flatList
                }
            }
            .navigationTitle("Library")
        }
        .sheet(item: $renameTarget) { video in
            RenameVideoSheet(video: video) { newTitle in
                libraryStore.rename(video, to: newTitle)
            }
        }
    }

    private var headerControls: some View {
        VStack(spacing: 8) {
            Picker("Sort", selection: $libraryStore.sortOption) {
                ForEach(LibraryStore.SortOption.allCases) { option in
                    Text(option.rawValue).tag(option)
                }
            }
            .pickerStyle(.segmented)

            Toggle("Group by date", isOn: $libraryStore.groupByDate)
                .toggleStyle(.switch)
        }
        .padding(.horizontal)
    }

    private var groupedList: some View {
        List {
            ForEach(libraryStore.groupedVideos, id: \.0) { group in
                Section(header: Text(group.0)) {
                    ForEach(group.1) { video in
                        NavigationLink(destination: VideoDetailView(video: video)) {
                            LibraryRow(video: video)
                        }
                        .contextMenu {
                            Button("Rename") {
                                renameTarget = video
                            }
                            Button(role: .destructive) {
                                libraryStore.delete(video)
                            } label: {
                                Text("Delete")
                            }
                        }
                        .swipeActions {
                            Button(role: .destructive) {
                                libraryStore.delete(video)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                            Button {
                                renameTarget = video
                            } label: {
                                Label("Rename", systemImage: "pencil")
                            }
                            .tint(.blue)
                        }
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
    }

    private var flatList: some View {
        List {
            ForEach(libraryStore.sortedVideos) { video in
                NavigationLink(destination: VideoDetailView(video: video)) {
                    LibraryRow(video: video)
                }
                .contextMenu {
                    Button("Rename") {
                        renameTarget = video
                    }
                    Button(role: .destructive) {
                        libraryStore.delete(video)
                    } label: {
                        Text("Delete")
                    }
                }
                .swipeActions {
                    Button(role: .destructive) {
                        libraryStore.delete(video)
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                    Button {
                        renameTarget = video
                    } label: {
                        Label("Rename", systemImage: "pencil")
                    }
                    .tint(.blue)
                }
            }
        }
        .listStyle(.insetGrouped)
    }
}

private struct LibraryRow: View {
    @EnvironmentObject var libraryStore: LibraryStore

    let video: DownloadedVideo

    var body: some View {
        HStack(spacing: 12) {
            ThumbnailView(video: video, fileURL: libraryStore.fileURL(for: video))
            VStack(alignment: .leading, spacing: 4) {
                Text(video.title)
                    .font(.headline)
                Text(video.downloadDate, style: .date)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                if let duration = video.duration {
                    Text("Duration: \(formatted(duration))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.vertical, 6)
    }

    private func formatted(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}
