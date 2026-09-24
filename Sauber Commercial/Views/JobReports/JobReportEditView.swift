import SwiftUI
import SwiftData

struct JobReportEditView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var profiles: [BusinessProfile]

    var report: JobReport?
    var job: WorkOrder

    @State private var workingReport: JobReport?
    @State private var createdDraft = false
    @State private var newChecklistText = ""

    var body: some View {
        Group {
            if let workingReport {
                form(for: workingReport)
            } else {
                ProgressView()
            }
        }
        .navigationTitle(report == nil ? "New Status Report" : "Edit Report")
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") { cancel() }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") { save() }
            }
        }
        .onAppear(perform: setup)
    }

    @ViewBuilder
    private func form(for report: JobReport) -> some View {
        Form {
            Section("Details") {
                TextField("Technician Name", text: Binding(
                    get: { report.technicianName },
                    set: { report.technicianName = $0 }
                ))
                TextField("Notes", text: Binding(
                    get: { report.notes },
                    set: { report.notes = $0 }
                ), axis: .vertical)
            }

            Section("Checklist") {
                ForEach(report.allChecklistItems) { item in
                    Button {
                        item.isDone.toggle()
                    } label: {
                        HStack {
                            Image(systemName: item.isDone ? "checkmark.circle.fill" : "circle")
                                .foregroundStyle(item.isDone ? .green : .secondary)
                            Text(item.text).foregroundStyle(.primary)
                        }
                    }
                }
                .onDelete { offsets in
                    let items = report.allChecklistItems
                    for index in offsets {
                        modelContext.delete(items[index])
                    }
                }

                HStack {
                    TextField("Add task", text: $newChecklistText)
                    Button("Add") {
                        addChecklistItem(to: report)
                    }
                    .disabled(newChecklistText.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }

            Section("Before Photos") {
                PhotoPickerGridView(
                    photos: report.beforePhotos,
                    onAdd: { data in addPhoto(data, role: .before, to: report) },
                    onDelete: { modelContext.delete($0) }
                )
            }

            Section("After Photos") {
                PhotoPickerGridView(
                    photos: report.afterPhotos,
                    onAdd: { data in addPhoto(data, role: .after, to: report) },
                    onDelete: { modelContext.delete($0) }
                )
            }
        }
    }

    private func addChecklistItem(to report: JobReport) {
        let sortOrder = (report.checklistItems ?? []).count
        let item = ChecklistItem(text: newChecklistText, sortOrder: sortOrder)
        item.jobReport = report
        modelContext.insert(item)
        newChecklistText = ""
    }

    private func addPhoto(_ data: Data, role: PhotoRole, to report: JobReport) {
        let sortOrder = (report.photos ?? []).count
        let attachment = PhotoAttachment(imageData: data, role: role, sortOrder: sortOrder)
        attachment.jobReport = report
        modelContext.insert(attachment)
    }

    private func setup() {
        guard workingReport == nil else { return }
        if let report {
            workingReport = report
        } else {
            let newReport = JobReport(technicianName: profiles.first?.ownerName ?? "")
            newReport.job = job
            modelContext.insert(newReport)
            workingReport = newReport
            createdDraft = true
        }
    }

    private func save() {
        try? modelContext.save()
        dismiss()
    }

    private func cancel() {
        if createdDraft, let workingReport {
            modelContext.delete(workingReport)
        }
        dismiss()
    }
}
