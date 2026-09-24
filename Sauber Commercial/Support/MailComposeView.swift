import SwiftUI
import MessageUI

/// Wraps MFMailComposeViewController so a PDF proposal or job report can be
/// emailed from inside the app using the user's own configured Mail account.
struct MailComposeView: UIViewControllerRepresentable {
    var recipient: String
    var subject: String
    var body: String
    var attachmentData: Data
    var attachmentFileName: String
    var onFinish: (MFMailComposeResult) -> Void

    func makeUIViewController(context: Context) -> MFMailComposeViewController {
        let composer = MFMailComposeViewController()
        composer.mailComposeDelegate = context.coordinator
        if !recipient.isEmpty {
            composer.setToRecipients([recipient])
        }
        composer.setSubject(subject)
        composer.setMessageBody(body, isHTML: false)
        composer.addAttachmentData(attachmentData, mimeType: "application/pdf", fileName: attachmentFileName)
        return composer
    }

    func updateUIViewController(_ uiViewController: MFMailComposeViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    final class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
        let parent: MailComposeView

        init(_ parent: MailComposeView) {
            self.parent = parent
        }

        func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
            controller.dismiss(animated: true) {
                self.parent.onFinish(result)
            }
        }
    }
}
