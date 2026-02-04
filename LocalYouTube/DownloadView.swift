import SwiftUI

struct DownloadView: View {
    @StateObject var viewModel: DownloadViewModel

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Video URL")) {
                    TextField("https://www.youtube.com/watch?v=...", text: $viewModel.videoURL)
                        .keyboardType(.URL)
                        .textContentType(.URL)
                        .autocapitalization(.none)
                }

                Section {
                    Button(action: viewModel.resolveStreams) {
                        if viewModel.isResolving {
                            ProgressView()
                        } else {
                            Text("Fetch Quality Options")
                        }
                    }
                    .disabled(viewModel.videoURL.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || viewModel.isResolving)

                    if let errorMessage = viewModel.errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                    }
                }

                if !viewModel.availableStreams.isEmpty {
                    Section(header: Text("Quality & Size")) {
                        Picker("Quality", selection: $viewModel.selectedStream) {
                            ForEach(viewModel.availableStreams) { stream in
                                VStack(alignment: .leading) {
                                    Text(stream.displayName)
                                        .font(.body)
                                    Text(stream.sizeDescription)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                .tag(Optional(stream))
                            }
                        }
                    }

                    Section {
                        Button(action: viewModel.downloadSelectedStream) {
                            if viewModel.isDownloading {
                                ProgressView()
                            } else {
                                Text("Download")
                            }
                        }
                        .disabled(viewModel.selectedStream == nil || viewModel.isDownloading)

                        if let progress = viewModel.downloadProgress {
                            ProgressView(value: progress)
                        }
                    }
                }

                if !viewModel.recentDownloads.isEmpty {
                    Section(header: Text("Offline Library")) {
                        ForEach(viewModel.recentDownloads, id: \.id) { download in
                            HStack(alignment: .top, spacing: 12) {
                                if let thumbnailURL = download.thumbnailURL, let url = URL(string: thumbnailURL) {
                                    AsyncImage(url: url) { image in
                                        image
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                    } placeholder: {
                                        Color.gray.opacity(0.2)
                                    }
                                    .frame(width: 72, height: 40)
                                    .clipped()
                                    .cornerRadius(6)
                                }

                                VStack(alignment: .leading, spacing: 4) {
                                    Text(download.title)
                                        .font(.headline)
                                    Text(download.resolution)
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    Text("Saved at \(download.localFilePath)")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Download")
            .onAppear(perform: viewModel.loadRecentDownloads)
        }
    }
}

struct DownloadView_Previews: PreviewProvider {
    static var previews: some View {
        DownloadView(viewModel: DownloadViewModel(downloadService: YouTubeDownloadService(), repository: DownloadRepository.preview))
    }
}
