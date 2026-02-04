import AVKit
import SwiftUI

struct LocalPlayerView: View {
    let url: URL

    @State private var player = AVPlayer()

    var body: some View {
        VideoPlayer(player: player)
            .onAppear {
                player.replaceCurrentItem(with: AVPlayerItem(url: url))
                player.play()
            }
            .onDisappear {
                player.pause()
            }
    }
}
