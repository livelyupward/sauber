import SwiftUI
import SwiftData

struct CustomerDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var customer: Customer

    @State private var isEditingCustomer = false
    @State private var isPresentingNewProposal = false
    @State private var isPresentingNewJob = false

    var body: some View {
        List {
            Section("Property") {
                if !customer.propertyManagerName.isEmpty {
                    LabeledContent("Property Manager", value: customer.propertyManagerName)
                }
                if !customer.phone.isEmpty {
                    LabeledContent("Phone", value: customer.phone)
                }
                if !customer.email.isEmpty {
                    LabeledContent("Email", value: customer.email)
                }
                if !customer.address.isEmpty {
                    LabeledContent("Address", value: customer.address)
                }
                if !customer.notes.isEmpty {
                    LabeledContent("Notes", value: customer.notes)
                }
            }

            Section {
                if customer.allProposals.isEmpty {
                    Text("No proposals yet.").foregroundStyle(.secondary)
                } else {
                    ForEach(customer.allProposals.sorted { $0.createdAt > $1.createdAt }) { proposal in
                        NavigationLink(value: proposal) {
                            ProposalRow(proposal: proposal)
                        }
                    }
                }
            } header: {
                HStack {
                    Text("Proposals")
                    Spacer()
                    Button { isPresentingNewProposal = true } label: { Image(systemName: "plus.circle") }
                }
            }

            Section {
                if customer.allJobs.isEmpty {
                    Text("No jobs yet.").foregroundStyle(.secondary)
                } else {
                    ForEach(customer.allJobs.sorted { $0.scheduledDate > $1.scheduledDate }) { job in
                        NavigationLink(value: job) {
                            JobRow(job: job)
                        }
                    }
                }
            } header: {
                HStack {
                    Text("Jobs")
                    Spacer()
                    Button { isPresentingNewJob = true } label: { Image(systemName: "plus.circle") }
                }
            }
        }
        .navigationTitle(customer.propertyName)
        .navigationDestination(for: Proposal.self) { proposal in
            ProposalDetailView(proposal: proposal)
        }
        .navigationDestination(for: WorkOrder.self) { job in
            JobDetailView(job: job)
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Edit") { isEditingCustomer = true }
            }
        }
        .sheet(isPresented: $isEditingCustomer) {
            NavigationStack {
                CustomerEditView(customer: customer)
            }
        }
        .sheet(isPresented: $isPresentingNewProposal) {
            NavigationStack {
                ProposalEditView(proposal: nil, presetCustomer: customer)
            }
        }
        .sheet(isPresented: $isPresentingNewJob) {
            NavigationStack {
                JobEditView(job: nil, presetCustomer: customer)
            }
        }
    }
}
