import SwiftUI
import SwiftData

struct JobDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var job: WorkOrder

    @State private var isEditing = false
    @State private var isPresentingNewReport = false

    var body: some View {
        List {
            Section {
                LabeledContent("Customer", value: job.customer?.displayName ?? "—")
                LabeledContent("Scheduled", value: Formatting.mediumDateTime.string(from: job.scheduledDate))
                Picker("Status", selection: Binding(
                    get: { job.status },
                    set: { job.status = $0 }
                )) {
                    ForEach(JobStatus.allCases) { status in
                        Text(status.label).tag(status)
                    }
                }
                if !job.jobDescription.isEmpty {
                    Text(job.jobDescription)
                }
            }

            Section {
                if job.allReports.isEmpty {
                    Text("No status reports yet.").foregroundStyle(.secondary)
                } else {
                    ForEach(job.allReports) { report in
                        NavigationLink(value: report) {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(Formatting.mediumDateTime.string(from: report.createdAt))
                                if !report.technicianName.isEmpty {
                                    Text(report.technicianName)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                    }
                }
            } header: {
                HStack {
                    Text("Status Reports")
                    Spacer()
                    Button { isPresentingNewReport = true } label: { Image(systemName: "plus.circle") }
                }
            }
        }
        .navigationTitle(job.title.isEmpty ? "Job" : job.title)
        .navigationDestination(for: JobReport.self) { report in
            JobReportDetailView(report: report)
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Edit") { isEditing = true }
            }
        }
        .sheet(isPresented: $isEditing) {
            NavigationStack {
                JobEditView(job: job, presetCustomer: job.customer)
            }
        }
        .sheet(isPresented: $isPresentingNewReport) {
            NavigationStack {
                JobReportEditView(report: nil, job: job)
            }
        }
    }
}
