import SwiftUI

/// Reusable grid for capturing/attaching photos and reviewing what's already
/// attached, with a delete affordance on each thumbnail.
struct PhotoPickerGridView: View {
    var photos: [PhotoAttachment]
    var onAdd: (Data) -> Void
    var onDelete: (PhotoAttachment) -> Void

    @State private var isShowingSourceDialog = false
    @State private var activeSource: ImagePicker.Source?

    private let columns = [GridItem(.adaptive(minimum: 84), spacing: 8)]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            LazyVGrid(columns: columns, spacing: 8) {
                ForEach(photos) { photo in
                    thumbnail(for: photo)
                }
                addButton
            }
        }
        .confirmationDialog("Add Photo", isPresented: $isShowingSourceDialog, titleVisibility: .visible) {
            Button("Take Photo") { activeSource = .camera }
            Button("Choose from Library") { activeSource = .photoLibrary }
            Button("Cancel", role: .cancel) {}
        }
        .sheet(item: $activeSource) { source in
            ImagePicker(source: source) { data in
                onAdd(data)
            }
            .ignoresSafeArea()
        }
    }

    private func thumbnail(for photo: PhotoAttachment) -> some View {
        ZStack(alignment: .topTrailing) {
            Group {
                if let uiImage = UIImage(data: photo.imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                } else {
                    Color(.secondarySystemBackground)
                }
            }
            .frame(width: 84, height: 84)
            .clipShape(RoundedRectangle(cornerRadius: 10))

            Button {
                onDelete(photo)
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .foregroundStyle(.white, .black.opacity(0.6))
            }
            .padding(4)
        }
    }

    private var addButton: some View {
        Button {
            isShowingSourceDialog = true
        } label: {
            RoundedRectangle(cornerRadius: 10)
                .stroke(style: StrokeStyle(lineWidth: 1, dash: [4]))
                .frame(width: 84, height: 84)
                .overlay(Image(systemName: "camera.fill").foregroundStyle(.secondary))
        }
    }
}

extension ImagePicker.Source: Identifiable {
    var id: Self { self }
}
