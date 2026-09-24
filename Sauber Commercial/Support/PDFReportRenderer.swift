import UIKit

enum PDFBlock {
    case heading(String)
    case body(String)
    case keyValue([(String, String)])
    case divider
    case spacer(CGFloat)
    case table(headers: [String], rows: [[String]], columnWidths: [CGFloat])
    case totalLine(String, String)
    case photoGrid(title: String?, images: [(image: UIImage, caption: String)])
    case beforeAfterGrid(pairs: [(before: UIImage?, after: UIImage?, caption: String)])
    case signatureBlock(image: UIImage?, signedName: String, signedDate: String?, label: String)
}

struct PDFDocumentSpec {
    var documentTitle: String
    var businessName: String
    var businessLogo: UIImage?
    var businessContactLines: [String]
    var blocks: [PDFBlock]
}

enum PDFReportRenderer {
    private static let pageWidth: CGFloat = 612
    private static let pageHeight: CGFloat = 792
    private static let margin: CGFloat = 40
    private static var contentWidth: CGFloat { pageWidth - margin * 2 }

    static func render(_ spec: PDFDocumentSpec) -> Data {
        let pageRect = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect)

        return renderer.pdfData { rendererContext in
            var y: CGFloat = margin

            func drawHeader() {
                var logoBottom = margin
                if let logo = spec.businessLogo {
                    let maxSide: CGFloat = 48
                    let scale = min(maxSide / logo.size.width, maxSide / logo.size.height, 1)
                    let size = CGSize(width: logo.size.width * scale, height: logo.size.height * scale)
                    logo.draw(in: CGRect(x: margin, y: margin, width: size.width, height: size.height))
                    logoBottom = margin + size.height
                }

                let nameAttrs: [NSAttributedString.Key: Any] = [
                    .font: UIFont.boldSystemFont(ofSize: 15),
                ]
                let contactAttrs: [NSAttributedString.Key: Any] = [
                    .font: UIFont.systemFont(ofSize: 9),
                    .foregroundColor: UIColor.darkGray,
                ]

                let nameString = NSAttributedString(string: spec.businessName, attributes: nameAttrs)
                var lineY = margin
                let nameSize = nameString.boundingRect(with: CGSize(width: 260, height: CGFloat.greatestFiniteMagnitude), options: [.usesLineFragmentOrigin], context: nil)
                nameString.draw(with: CGRect(x: pageWidth - margin - 260, y: lineY, width: 260, height: nameSize.height), options: [.usesLineFragmentOrigin], context: nil)
                lineY += nameSize.height + 2

                for line in spec.businessContactLines {
                    let s = NSAttributedString(string: line, attributes: contactAttrs)
                    let size = s.boundingRect(with: CGSize(width: 260, height: CGFloat.greatestFiniteMagnitude), options: [.usesLineFragmentOrigin], context: nil)
                    s.draw(with: CGRect(x: pageWidth - margin - 260, y: lineY, width: 260, height: size.height), options: [.usesLineFragmentOrigin], context: nil)
                    lineY += size.height + 1
                }

                y = max(logoBottom, lineY) + 10

                let titleAttrs: [NSAttributedString.Key: Any] = [.font: UIFont.boldSystemFont(ofSize: 22)]
                let titleString = NSAttributedString(string: spec.documentTitle, attributes: titleAttrs)
                titleString.draw(at: CGPoint(x: margin, y: y))
                y += 30

                let ctx = rendererContext.cgContext
                ctx.setStrokeColor(UIColor.lightGray.cgColor)
                ctx.setLineWidth(0.75)
                ctx.move(to: CGPoint(x: margin, y: y))
                ctx.addLine(to: CGPoint(x: pageWidth - margin, y: y))
                ctx.strokePath()
                y += 16
            }

            func startPage() {
                rendererContext.beginPage()
                y = margin
                drawHeader()
            }

            func ensureSpace(_ height: CGFloat) {
                if y + height > pageHeight - margin {
                    startPage()
                }
            }

            func drawAttributed(_ text: String, font: UIFont, color: UIColor = .black, spacingAfter: CGFloat = 6, width: CGFloat = contentWidth) {
                guard !text.isEmpty else { return }
                let attrs: [NSAttributedString.Key: Any] = [.font: font, .foregroundColor: color]
                let attrString = NSAttributedString(string: text, attributes: attrs)
                let bounding = attrString.boundingRect(with: CGSize(width: width, height: CGFloat.greatestFiniteMagnitude), options: [.usesLineFragmentOrigin], context: nil)
                ensureSpace(bounding.height + spacingAfter)
                attrString.draw(with: CGRect(x: margin, y: y, width: width, height: ceil(bounding.height)), options: [.usesLineFragmentOrigin], context: nil)
                y += ceil(bounding.height) + spacingAfter
            }

            func drawTable(headers: [String], rows: [[String]], columnWidths: [CGFloat]) {
                let rowPadding: CGFloat = 6
                let headerFont = UIFont.boldSystemFont(ofSize: 10)
                let cellFont = UIFont.systemFont(ofSize: 10)

                func columnX(_ index: Int) -> CGFloat {
                    margin + columnWidths.prefix(index).reduce(0, +)
                }

                func drawRow(_ cells: [String], font: UIFont, isHeader: Bool) {
                    var maxHeight: CGFloat = 0
                    var heights: [CGFloat] = []
                    for (i, cell) in cells.enumerated() {
                        let attrs: [NSAttributedString.Key: Any] = [.font: font]
                        let s = NSAttributedString(string: cell, attributes: attrs)
                        let bounding = s.boundingRect(with: CGSize(width: columnWidths[i] - 8, height: CGFloat.greatestFiniteMagnitude), options: [.usesLineFragmentOrigin], context: nil)
                        heights.append(ceil(bounding.height))
                        maxHeight = max(maxHeight, ceil(bounding.height))
                    }
                    let rowHeight = maxHeight + rowPadding * 2
                    ensureSpace(rowHeight)

                    if isHeader {
                        rendererContext.cgContext.setFillColor(UIColor(white: 0.93, alpha: 1).cgColor)
                        rendererContext.cgContext.fill(CGRect(x: margin, y: y, width: contentWidth, height: rowHeight))
                    }

                    for (i, cell) in cells.enumerated() {
                        let alignRight = i > 0
                        let paragraph = NSMutableParagraphStyle()
                        paragraph.alignment = alignRight ? .right : .left
                        let attrs: [NSAttributedString.Key: Any] = [.font: font, .paragraphStyle: paragraph]
                        let s = NSAttributedString(string: cell, attributes: attrs)
                        s.draw(with: CGRect(x: columnX(i) + 4, y: y + rowPadding, width: columnWidths[i] - 8, height: heights[i]), options: [.usesLineFragmentOrigin], context: nil)
                    }
                    y += rowHeight
                    rendererContext.cgContext.setStrokeColor(UIColor(white: 0.85, alpha: 1).cgColor)
                    rendererContext.cgContext.setLineWidth(0.5)
                    rendererContext.cgContext.move(to: CGPoint(x: margin, y: y))
                    rendererContext.cgContext.addLine(to: CGPoint(x: margin + contentWidth, y: y))
                    rendererContext.cgContext.strokePath()
                }

                drawRow(headers, font: headerFont, isHeader: true)
                for row in rows {
                    drawRow(row, font: cellFont, isHeader: false)
                }
                y += 8
            }

            func drawPhotoGrid(images: [(image: UIImage, caption: String)]) {
                guard !images.isEmpty else { return }
                let columns = 3
                let spacing: CGFloat = 10
                let cellWidth = (contentWidth - spacing * CGFloat(columns - 1)) / CGFloat(columns)
                let cellImageHeight: CGFloat = cellWidth * 0.75
                let captionHeight: CGFloat = 12
                let cellHeight = cellImageHeight + captionHeight + 6

                var index = 0
                while index < images.count {
                    ensureSpace(cellHeight)
                    let rowStartY = y
                    for col in 0..<columns {
                        guard index < images.count else { break }
                        let entry = images[index]
                        let x = margin + CGFloat(col) * (cellWidth + spacing)
                        let imageRect = CGRect(x: x, y: rowStartY, width: cellWidth, height: cellImageHeight)
                        drawAspectFitImage(entry.image, in: imageRect)
                        let captionAttrs: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: 8), .foregroundColor: UIColor.darkGray]
                        NSAttributedString(string: entry.caption, attributes: captionAttrs)
                            .draw(with: CGRect(x: x, y: rowStartY + cellImageHeight + 2, width: cellWidth, height: captionHeight), options: [.usesLineFragmentOrigin], context: nil)
                        index += 1
                    }
                    y = rowStartY + cellHeight
                }
                y += 4
            }

            func drawAspectFitImage(_ image: UIImage, in rect: CGRect) {
                rendererContext.cgContext.setStrokeColor(UIColor(white: 0.85, alpha: 1).cgColor)
                rendererContext.cgContext.stroke(rect)
                let imageAspect = image.size.width / max(image.size.height, 1)
                let rectAspect = rect.width / rect.height
                var drawRect = rect
                if imageAspect > rectAspect {
                    let h = rect.width / imageAspect
                    drawRect = CGRect(x: rect.minX, y: rect.minY + (rect.height - h) / 2, width: rect.width, height: h)
                } else {
                    let w = rect.height * imageAspect
                    drawRect = CGRect(x: rect.minX + (rect.width - w) / 2, y: rect.minY, width: w, height: rect.height)
                }
                image.draw(in: drawRect)
            }

            func drawBeforeAfter(pairs: [(before: UIImage?, after: UIImage?, caption: String)]) {
                guard !pairs.isEmpty else { return }
                let spacing: CGFloat = 10
                let cellWidth = (contentWidth - spacing) / 2
                let cellImageHeight: CGFloat = cellWidth * 0.7
                let labelHeight: CGFloat = 12
                let captionHeight: CGFloat = 12
                let rowHeight = labelHeight + cellImageHeight + captionHeight + 8

                for pair in pairs {
                    ensureSpace(rowHeight)
                    let rowY = y
                    let labelAttrs: [NSAttributedString.Key: Any] = [.font: UIFont.boldSystemFont(ofSize: 9)]

                    NSAttributedString(string: "BEFORE", attributes: labelAttrs).draw(at: CGPoint(x: margin, y: rowY))
                    NSAttributedString(string: "AFTER", attributes: labelAttrs).draw(at: CGPoint(x: margin + cellWidth + spacing, y: rowY))

                    let beforeRect = CGRect(x: margin, y: rowY + labelHeight, width: cellWidth, height: cellImageHeight)
                    let afterRect = CGRect(x: margin + cellWidth + spacing, y: rowY + labelHeight, width: cellWidth, height: cellImageHeight)

                    if let before = pair.before {
                        drawAspectFitImage(before, in: beforeRect)
                    } else {
                        rendererContext.cgContext.setStrokeColor(UIColor(white: 0.85, alpha: 1).cgColor)
                        rendererContext.cgContext.stroke(beforeRect)
                    }
                    if let after = pair.after {
                        drawAspectFitImage(after, in: afterRect)
                    } else {
                        rendererContext.cgContext.setStrokeColor(UIColor(white: 0.85, alpha: 1).cgColor)
                        rendererContext.cgContext.stroke(afterRect)
                    }

                    if !pair.caption.isEmpty {
                        let captionAttrs: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: 8), .foregroundColor: UIColor.darkGray]
                        NSAttributedString(string: pair.caption, attributes: captionAttrs)
                            .draw(at: CGPoint(x: margin, y: rowY + labelHeight + cellImageHeight + 2))
                    }
                    y = rowY + rowHeight
                }
            }

            func drawSignature(image: UIImage?, signedName: String, signedDate: String?, label: String) {
                let blockHeight: CGFloat = 90
                ensureSpace(blockHeight)
                let labelAttrs: [NSAttributedString.Key: Any] = [.font: UIFont.boldSystemFont(ofSize: 10)]
                NSAttributedString(string: label, attributes: labelAttrs).draw(at: CGPoint(x: margin, y: y))
                y += 16

                let sigRect = CGRect(x: margin, y: y, width: 220, height: 50)
                if let image {
                    drawAspectFitImage(image, in: sigRect)
                } else {
                    rendererContext.cgContext.setStrokeColor(UIColor(white: 0.85, alpha: 1).cgColor)
                    rendererContext.cgContext.stroke(sigRect)
                }
                y += 54

                var line = signedName
                if let signedDate, !signedDate.isEmpty {
                    line += "  •  \(signedDate)"
                }
                if !line.isEmpty {
                    drawAttributed(line, font: .systemFont(ofSize: 9), color: .darkGray, spacingAfter: 4)
                }
            }

            startPage()

            for block in spec.blocks {
                switch block {
                case .heading(let text):
                    ensureSpace(20)
                    drawAttributed(text, font: .boldSystemFont(ofSize: 13), spacingAfter: 8)
                case .body(let text):
                    drawAttributed(text, font: .systemFont(ofSize: 10.5), spacingAfter: 10)
                case .keyValue(let pairs):
                    for (key, value) in pairs {
                        drawAttributed("\(key): \(value)", font: .systemFont(ofSize: 10.5), spacingAfter: 3)
                    }
                    y += 6
                case .divider:
                    ensureSpace(10)
                    rendererContext.cgContext.setStrokeColor(UIColor.lightGray.cgColor)
                    rendererContext.cgContext.setLineWidth(0.5)
                    rendererContext.cgContext.move(to: CGPoint(x: margin, y: y))
                    rendererContext.cgContext.addLine(to: CGPoint(x: margin + contentWidth, y: y))
                    rendererContext.cgContext.strokePath()
                    y += 12
                case .spacer(let height):
                    y += height
                case .table(let headers, let rows, let columnWidths):
                    drawTable(headers: headers, rows: rows, columnWidths: columnWidths)
                case .totalLine(let label, let value):
                    ensureSpace(24)
                    let paragraph = NSMutableParagraphStyle()
                    paragraph.alignment = .right
                    let attrs: [NSAttributedString.Key: Any] = [.font: UIFont.boldSystemFont(ofSize: 13), .paragraphStyle: paragraph]
                    NSAttributedString(string: "\(label)  \(value)", attributes: attrs)
                        .draw(with: CGRect(x: margin, y: y, width: contentWidth, height: 20), options: [.usesLineFragmentOrigin], context: nil)
                    y += 26
                case .photoGrid(let title, let images):
                    if let title {
                        drawAttributed(title, font: .boldSystemFont(ofSize: 11), spacingAfter: 6)
                    }
                    drawPhotoGrid(images: images)
                case .beforeAfterGrid(let pairs):
                    drawBeforeAfter(pairs: pairs)
                case .signatureBlock(let image, let signedName, let signedDate, let label):
                    drawSignature(image: image, signedName: signedName, signedDate: signedDate, label: label)
                }
            }
        }
    }
}
