import SwiftUI

/// A simple finger-drawing signature pad. Exposes the current strokes as
/// PNG data via `render()` so callers can save it to a model.
struct SignaturePadView: View {
    @Binding var strokes: [[CGPoint]]
    @State private var currentStroke: [CGPoint] = []

    var body: some View {
        Canvas { context, size in
            var path = Path()
            for stroke in strokes {
                appendStroke(stroke, to: &path)
            }
            appendStroke(currentStroke, to: &path)
            context.stroke(path, with: .color(.primary), style: StrokeStyle(lineWidth: 2.5, lineCap: .round, lineJoin: .round))
        }
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { value in
                    currentStroke.append(value.location)
                }
                .onEnded { _ in
                    if !currentStroke.isEmpty {
                        strokes.append(currentStroke)
                        currentStroke = []
                    }
                }
        )
    }

    private func appendStroke(_ stroke: [CGPoint], to path: inout Path) {
        guard let first = stroke.first else { return }
        path.move(to: first)
        for point in stroke.dropFirst() {
            path.addLine(to: point)
        }
    }

    var isEmpty: Bool { strokes.isEmpty && currentStroke.isEmpty }
}

@MainActor
enum SignatureRenderer {
    static func render(strokes: [[CGPoint]], size: CGSize) -> Data? {
        let renderer = ImageRenderer(content:
            Canvas { context, _ in
                var path = Path()
                for stroke in strokes {
                    guard let first = stroke.first else { continue }
                    path.move(to: first)
                    for point in stroke.dropFirst() {
                        path.addLine(to: point)
                    }
                }
                context.stroke(path, with: .color(.black), style: StrokeStyle(lineWidth: 2.5, lineCap: .round, lineJoin: .round))
            }
            .frame(width: size.width, height: size.height)
            .background(Color.white)
        )
        renderer.scale = UIScreen.main.scale
        guard let uiImage = renderer.uiImage else { return nil }
        return uiImage.pngData()
    }
}
