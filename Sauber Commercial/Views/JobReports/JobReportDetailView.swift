import SwiftUI
import SwiftData

struct JobReportDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var report: JobReport
    @Query private var profiles: [BusinessProfile]

    @State private var isEditing = false
    @State private var isPresentingSignature = false
    @State private var isPresentingPreview = false
    @State private var generatedPDFData: Data?

    private var businessProfile: BusinessProfile? { profiles.first }

    var body: some View {
        List {
            Section {
                LabeledContent("Date", value: Formatting.mediumDateTime.string(from: report.createdAt))
                if !report.technicianName.isEmpty {
                    LabeledContent("Technician", value: report.technicianName)
                }
                if !report.notes.isEmpty {
                    Text(report.notes)
                }
            }

            if !report.allChecklistItems.isEmpty {
                Section("Checklist") {
                    ForEach(report.allChecklistItems) { item in
                        HStack {
                            Image(systemName: item.isDone ? "checkmark.circle.fill" : "circle")
                                .foregroundStyle(item.isDone ? .green : .secondary)
                            Text(item.text)
                        }
                    }
                }
            }

            if !report.beforePhotos.isEmpty {
                photoSection(title: "Before", photos: report.beforePhotos)
            }
            if !report.afterPhotos.isEmpty {
                photoSection(title: "After", photos: report.afterPhotos)
            }

            Section("Confirmation") {
                if report.isSigned {
                    LabeledContent("Confirmed by", value: report.signedName)
                    if let signedAt = report.signedAt {
                        LabeledContent("Signed on", value: Formatting.mediumDate.string(from: signedAt))
                    }
                } else {
                    Button("Capture Customer Signature") { isPresentingSignature = true }
                }
            }

            Section {
                Button {
                    generatedPDFData = JobReportPDFGenerator.generate(report: report, businessProfile: businessProfile)
                    isPresentingPreview = true
                } label: {
                    Label("Preview / Send PDF", systemImage: "doc.richtext")
                }
            }
        }
        .navigationTitle("Status Report")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Edit") { isEditing = true }
            }
        }
        .sheet(isPresented: $isEditing) {
            NavigationStack {
                JobReportEditView(report: report, job: report.job ?? WorkOrder())
            }
        }
        .sheet(isPresented: $isPresentingSignature) {
            SignatureCaptureSheet(title: "Confirm Completion") { data, name in
                report.signatureData = data
                report.signedName = name
                report.signedAt = Date()
                try? modelContext.save()
            }
        }
        .sheet(isPresented: $isPresentingPreview) {
            if let generatedPDFData {
                PDFPreviewSheet(
                    title: "Job Report",
                    pdfData: generatedPDFData,
                    fileName: "Job Report.pdf",
                    recipientEmail: report.job?.customer?.email ?? "",
                    emailSubject: "Job Completion Report from \(businessProfile?.businessName ?? "us")",
                    emailBody: "Hi \(report.job?.customer?.propertyManagerName ?? ""),\n\nHere's a report on the work completed at \(report.job?.customer?.propertyName ?? "your property").\n\nThanks,\n\(businessProfile?.ownerName ?? "")"
                )
            }
        }
    }

    private func photoSection(title: String, photos: [PhotoAttachment]) -> some View {
        Section(title) {
            ScrollView(.horizontal) {
                HStack {
                    ForEach(photos) { photo in
                        if let uiImage = UIImage(data: photo.imageData) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 90, height: 90)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                    }
                }
            }
        }
    }
}
