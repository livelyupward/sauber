import UIKit

enum JobReportPDFGenerator {
    static func generate(report: JobReport, businessProfile: BusinessProfile?) -> Data {
        var blocks: [PDFBlock] = []

        let job = report.job
        let customer = job?.customer

        var infoLines: [(String, String)] = []
        if let customer {
            infoLines.append(("Customer", customer.propertyName))
            if !customer.propertyManagerName.isEmpty { infoLines.append(("Property Manager", customer.propertyManagerName)) }
            if !customer.address.isEmpty { infoLines.append(("Address", customer.address)) }
            if !customer.phone.isEmpty { infoLines.append(("Phone Number", customer.phone)) }
        }
        if let job, !job.title.isEmpty {
            infoLines.append(("Job", job.title))
        }
        infoLines.append(("Date", Formatting.mediumDateTime.string(from: report.createdAt)))
        if !report.technicianName.isEmpty {
            infoLines.append(("Technician", report.technicianName))
        }
        blocks.append(.keyValue(infoLines))
        blocks.append(.divider)

        if let job, !job.jobDescription.isEmpty {
            blocks.append(.heading("Job Description"))
            blocks.append(.body(job.jobDescription))
        }

        let checklist = report.allChecklistItems
        if !checklist.isEmpty {
            blocks.append(.heading("Completed Tasks"))
            let rows = checklist.map { [$0.isDone ? "✓" : "—", $0.text] }
            blocks.append(.table(headers: ["", "Task"], rows: rows, columnWidths: [24, 484]))
        }

        if !report.notes.isEmpty {
            blocks.append(.spacer(4))
            blocks.append(.heading("Notes"))
            blocks.append(.body(report.notes))
        }

        let beforeByCaption = Dictionary(grouping: report.beforePhotos, by: { $0.caption })
        let afterByCaption = Dictionary(grouping: report.afterPhotos, by: { $0.caption })
        let allCaptions = Set(beforeByCaption.keys).union(afterByCaption.keys)
        if !report.beforePhotos.isEmpty || !report.afterPhotos.isEmpty {
            blocks.append(.spacer(4))
            blocks.append(.heading("Before & After"))
            if allCaptions.count <= 1, (report.beforePhotos.count > 1 || report.afterPhotos.count > 1) {
                // Fall back to pairing by index when captions aren't used to match photos.
                let count = max(report.beforePhotos.count, report.afterPhotos.count)
                var pairs: [(before: UIImage?, after: UIImage?, caption: String)] = []
                for i in 0..<count {
                    let before = i < report.beforePhotos.count ? UIImage(data: report.beforePhotos[i].imageData) : nil
                    let after = i < report.afterPhotos.count ? UIImage(data: report.afterPhotos[i].imageData) : nil
                    pairs.append((before, after, ""))
                }
                blocks.append(.beforeAfterGrid(pairs: pairs))
            } else {
                var pairs: [(before: UIImage?, after: UIImage?, caption: String)] = []
                for caption in allCaptions.sorted() {
                    let before = beforeByCaption[caption]?.first.flatMap { UIImage(data: $0.imageData) }
                    let after = afterByCaption[caption]?.first.flatMap { UIImage(data: $0.imageData) }
                    pairs.append((before, after, caption))
                }
                blocks.append(.beforeAfterGrid(pairs: pairs))
            }
        }

        let generalPhotos = report.generalPhotos.compactMap { attachment -> (image: UIImage, caption: String)? in
            guard let image = UIImage(data: attachment.imageData) else { return nil }
            return (image, attachment.caption)
        }
        if !generalPhotos.isEmpty {
            blocks.append(.spacer(4))
            blocks.append(.photoGrid(title: "Additional Photos", images: generalPhotos))
        }

        if report.isSigned || !report.signedName.isEmpty {
            blocks.append(.spacer(8))
            let signatureImage = report.signatureData.flatMap { UIImage(data: $0) }
            blocks.append(.signatureBlock(
                image: signatureImage,
                signedName: report.signedName,
                signedDate: report.signedAt.map { Formatting.mediumDate.string(from: $0) },
                label: "Confirmed by"
            ))
        }

        let spec = PDFDocumentSpec(
            documentTitle: "Job Completion Report",
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
