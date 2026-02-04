import SwiftUI

struct RenameVideoSheet: View {
    let video: DownloadedVideo
    let onSave: (String) -> Void

    @State private var title: String
    @Environment(\.dismiss) private var dismiss

    init(video: DownloadedVideo, onSave: @escaping (String) -> Void) {
        self.video = video
        self.onSave = onSave
        _title = State(initialValue: video.title)
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Title")) {
                    TextField("Video title", text: $title)
                }
            }
            .navigationTitle("Rename")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        onSave(title)
                        dismiss()
                    }
                    .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
}
