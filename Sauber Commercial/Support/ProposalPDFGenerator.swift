import UIKit

enum ProposalPDFGenerator {
    static func generate(proposal: Proposal, businessProfile: BusinessProfile?) -> Data {
        var blocks: [PDFBlock] = []

        let customer = proposal.customer
        var customerLines: [(String, String)] = []
        if let customer {
            customerLines.append(("Customer", customer.propertyName))
            if !customer.propertyManagerName.isEmpty { customerLines.append(("Property Manager", customer.propertyManagerName)) }
            if !customer.address.isEmpty { customerLines.append(("Address", customer.address)) }
            if !customer.phone.isEmpty { customerLines.append(("Phone Number", customer.phone)) }
            if !customer.email.isEmpty { customerLines.append(("Email", customer.email)) }
        }
        customerLines.append(("Date", Formatting.mediumDate.string(from: proposal.createdAt)))
        if let validUntil = proposal.validUntil {
            customerLines.append(("Valid until", Formatting.mediumDate.string(from: validUntil)))
        }
        blocks.append(.keyValue(customerLines))
        blocks.append(.divider)

        if !proposal.title.isEmpty {
            blocks.append(.heading(proposal.title))
        }

        let lineItems = proposal.allLineItems
        if !lineItems.isEmpty {
            let columnWidths: [CGFloat] = [268, 60, 90, 90]
            let rows = lineItems.map { item -> [String] in
                [
                    item.itemDescription,
                    Formatting.quantityString(item.quantity),
                    Formatting.currencyString(item.unitPrice),
                    Formatting.currencyString(item.lineTotal),
                ]
            }
            blocks.append(.table(headers: ["Description", "Qty", "Unit Price", "Total"], rows: rows, columnWidths: columnWidths))
            blocks.append(.totalLine("Total:", Formatting.currencyString(proposal.total)))
        }

        if !proposal.notes.isEmpty {
            blocks.append(.spacer(4))
            blocks.append(.heading("Notes"))
            blocks.append(.body(proposal.notes))
        }

        let photos = proposal.allPhotos.compactMap { attachment -> (image: UIImage, caption: String)? in
            guard let image = UIImage(data: attachment.imageData) else { return nil }
            return (image, attachment.caption)
        }
        if !photos.isEmpty {
            blocks.append(.spacer(4))
            blocks.append(.photoGrid(title: "Site Photos", images: photos))
        }

        if proposal.isSigned || !proposal.signedName.isEmpty {
            blocks.append(.spacer(8))
            let signatureImage = proposal.signatureData.flatMap { UIImage(data: $0) }
            blocks.append(.signatureBlock(
                image: signatureImage,
                signedName: proposal.signedName,
                signedDate: proposal.signedAt.map { Formatting.mediumDate.string(from: $0) },
                label: "Accepted by"
            ))
        }

        let spec = PDFDocumentSpec(
            documentTitle: "Proposal",
            businessName: businessProfile?.businessName ?? "",
            businessLogo: businessProfile?.logoData.flatMap { UIImage(data: $0) },
            businessContactLines: contactLines(for: businessProfile),
            blocks: blocks
        )
        return PDFReportRenderer.render(spec)
    }

    private static func contactLines(for profile: BusinessProfile?) -> [String] {
        guard let profile else { return [] }
        var lines: [String] = []
        if !profile.address.isEmpty { lines.append(profile.address) }
        if !profile.phone.isEmpty { lines.append(profile.phone) }
        if !profile.email.isEmpty { lines.append(profile.email) }
        if !profile.website.isEmpty { lines.append(profile.website) }
        return lines
    }
}
