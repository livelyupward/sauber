import SwiftUI
import MessageUI

struct PDFPreviewSheet: View {
    @Environment(\.dismiss) private var dismiss

    var title: String
    var pdfData: Data
    var fileName: String
    var recipientEmail: String
    var emailSubject: String
    var emailBody: String
    var onSent: (() -> Void)?

    @State private var isShowingMailComposer = false
    @State private var isShowingShareSheet = false
    @State private var mailResultMessage: String?

    var body: some View {
        NavigationStack {
            PDFKitView(data: pdfData)
                .navigationTitle(title)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Close") { dismiss() }
                    }
                    ToolbarItemGroup(placement: .primaryAction) {
                        Button {
                            isShowingShareSheet = true
                        } label: {
                            Image(systemName: "square.and.arrow.up")
                        }
                        Button {
                            isShowingMailComposer = true
                        } label: {
                            Image(systemName: "envelope")
                        }
                    }
                }
                .sheet(isPresented: $isShowingShareSheet) {
                    ShareSheet(items: [tempFileURL()].compactMap { $0 })
                }
                .sheet(isPresented: $isShowingMailComposer) {
                    if MFMailComposeViewController.canSendMail() {
                        MailComposeView(
                            recipient: recipientEmail,
                            subject: emailSubject,
                            body: emailBody,
                            attachmentData: pdfData,
                            attachmentFileName: fileName
                        ) { result in
                            if result == .sent {
                                onSent?()
                            }
                        }
                    } else {
                        VStack(spacing: 16) {
                            Text("No Email Account Set Up")
                                .font(.headline)
                            Text("Add a Mail account in iOS Settings, or use Share to send this PDF another way.")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }
                        .padding()
                    }
                }
        }
    }

    private func tempFileURL() -> URL? {
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        do {
            try pdfData.write(to: url, options: .atomic)
            return url
        } catch {
            return nil
        }
    }
}
