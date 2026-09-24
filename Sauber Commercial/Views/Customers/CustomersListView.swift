import SwiftUI
import SwiftData

struct CustomersListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Customer.propertyName) private var customers: [Customer]

    @State private var isPresentingNew = false
    @State private var searchText = ""

    private var filtered: [Customer] {
        guard !searchText.isEmpty else { return customers }
        return customers.filter {
            $0.propertyName.localizedCaseInsensitiveContains(searchText) ||
            $0.propertyManagerName.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        List {
            if customers.isEmpty {
                ContentUnavailableView(
                    "No Customers Yet",
                    systemImage: "building.2",
                    description: Text("Customers are added automatically when a proposal is accepted, or you can add one directly.")
                )
            } else {
                ForEach(filtered) { customer in
                    NavigationLink(value: customer) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(customer.propertyName)
                            if !customer.propertyManagerName.isEmpty {
                                Text(customer.propertyManagerName)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
                .onDelete(perform: delete)
            }
        }
        .searchable(text: $searchText)
        .navigationTitle("Customers")
        .navigationDestination(for: Customer.self) { customer in
            CustomerDetailView(customer: customer)
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button { isPresentingNew = true } label: { Image(systemName: "plus") }
            }
        }
        .sheet(isPresented: $isPresentingNew) {
            NavigationStack {
                CustomerEditView(customer: nil)
            }
        }
    }

    private func delete(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(filtered[index])
        }
    }
}
