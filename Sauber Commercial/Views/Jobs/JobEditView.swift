import SwiftUI
import SwiftData

struct JobEditView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    var job: WorkOrder?
    var presetCustomer: Customer?

    @State private var title = ""
    @State private var jobDescription = ""
    @State private var scheduledDate = Date()
    @State private var status: JobStatus = .scheduled
    @State private var customer: Customer?
    @State private var isPresentingCustomerPicker = false

    private var isNew: Bool { job == nil }

    var body: some View {
        Form {
            Section("Customer") {
                if let customer {
                    HStack {
                        Text(customer.displayName)
                        Spacer()
                        if presetCustomer == nil {
                            Button("Change") { isPresentingCustomerPicker = true }
                        }
                    }
                } else {
                    Button("Select Customer") { isPresentingCustomerPicker = true }
                }
            }

            Section("Job") {
                TextField("Title", text: $title)
                TextField("Description", text: $jobDescription, axis: .vertical)
                DatePicker("Scheduled Date", selection: $scheduledDate, displayedComponents: [.date, .hourAndMinute])
                Picker("Status", selection: $status) {
                    ForEach(JobStatus.allCases) { status in
                        Text(status.label).tag(status)
                    }
                }
            }
        }
        .navigationTitle(isNew ? "New Job" : "Edit Job")
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") { dismiss() }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") { save() }
                    .disabled(customer == nil || title.trimmingCharacters(in: .whitespaces).isEmpty)
            }
        }
        .sheet(isPresented: $isPresentingCustomerPicker) {
            NavigationStack {
                CustomerPickerView { selected in
                    customer = selected
                }
            }
        }
        .onAppear {
            customer = job?.customer ?? presetCustomer
            if let job {
                title = job.title
                jobDescription = job.jobDescription
                scheduledDate = job.scheduledDate
                status = job.status
            }
        }
    }

    private func save() {
        if let job {
            job.title = title
            job.jobDescription = jobDescription
            job.scheduledDate = scheduledDate
            job.status = status
            job.customer = customer
        } else {
            let newJob = WorkOrder(title: title, jobDescription: jobDescription, status: status, scheduledDate: scheduledDate)
            newJob.customer = customer
            modelContext.insert(newJob)
        }
        try? modelContext.save()
        dismiss()
    }
}
