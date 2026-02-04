import SwiftUI

struct ThumbnailView: View {
    let video: DownloadedVideo
    let fileURL: URL

    @State private var image: Image?

    var body: some View {
        ZStack {
            if let image {
                image
                    .resizable()
                    .scaledToFill()
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                Image(systemName: "film")
                    .font(.title2)
                    .foregroundColor(.gray)
            }
        }
        .frame(width: 120, height: 68)
        .clipped()
        .task {
            await loadThumbnail()
        }
    }

    private func loadThumbnail() async {
        if let uiImage = await ThumbnailCache.shared.thumbnail(for: video, fileURL: fileURL) {
            image = Image(uiImage: uiImage)
        }
    }
}
