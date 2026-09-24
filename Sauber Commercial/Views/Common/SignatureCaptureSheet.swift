import SwiftUI

struct SignatureCaptureSheet: View {
    @Environment(\.dismiss) private var dismiss

    var title: String
    var onSave: (Data, String) -> Void

    @State private var strokes: [[CGPoint]] = []
    @State private var signedName = ""

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                TextField("Full Name", text: $signedName)
                    .textFieldStyle(.roundedBorder)
                    .padding(.horizontal)

                SignaturePadView(strokes: $strokes)
                    .frame(height: 220)
                    .padding(.horizontal)

                Button("Clear") { strokes = [] }
                    .disabled(strokes.isEmpty)

                Spacer()
            }
            .padding(.top)
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Confirm") {
                        guard let data = SignatureRenderer.render(strokes: strokes, size: CGSize(width: 600, height: 220)) else { return }
                        onSave(data, signedName)
                        dismiss()
                    }
                    .disabled(strokes.isEmpty || signedName.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }
}
