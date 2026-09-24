import SwiftUI
import SwiftData

struct ProposalsListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Proposal.createdAt, order: .reverse) private var proposals: [Proposal]

    @State private var isPresentingNew = false
    @State private var statusFilter: ProposalStatus?

    private var filtered: [Proposal] {
        guard let statusFilter else { return proposals }
        return proposals.filter { $0.status == statusFilter }
    }

    var body: some View {
        List {
            if proposals.isEmpty {
                ContentUnavailableView(
                    "No Proposals Yet",
                    systemImage: "doc.text",
                    description: Text("Create a proposal to send to a prospective customer.")
                )
            } else {
                ForEach(filtered) { proposal in
                    NavigationLink(value: proposal) {
                        ProposalRow(proposal: proposal)
                    }
                }
                .onDelete(perform: delete)
            }
        }
        .navigationTitle("Proposals")
        .navigationDestination(for: Proposal.self) { proposal in
            ProposalDetailView(proposal: proposal)
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button { isPresentingNew = true } label: { Image(systemName: "plus") }
            }
            ToolbarItem(placement: .secondaryAction) {
                Menu {
                    Button("All") { statusFilter = nil }
                    ForEach(ProposalStatus.allCases) { status in
                        Button(status.label) { statusFilter = status }
                    }
                } label: {
                    Label("Filter", systemImage: "line.3.horizontal.decrease.circle")
                }
            }
        }
        .sheet(isPresented: $isPresentingNew) {
            NavigationStack {
                ProposalEditView(proposal: nil, presetCustomer: nil)
            }
        }
    }

    private func delete(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(filtered[index])
        }
    }
}
