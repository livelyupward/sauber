import SwiftUI
import SwiftData

struct CustomerPickerView: View {
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \Customer.propertyName) private var customers: [Customer]

    var onSelect: (Customer) -> Void

    @State private var searchText = ""
    @State private var isPresentingNewCustomer = false

    private var filtered: [Customer] {
        guard !searchText.isEmpty else { return customers }
        return customers.filter {
            $0.propertyName.localizedCaseInsensitiveContains(searchText) ||
            $0.propertyManagerName.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        List {
            Button {
                isPresentingNewCustomer = true
            } label: {
                Label("New Customer", systemImage: "building.2")
            }

            ForEach(filtered) { customer in
                Button {
                    onSelect(customer)
                    dismiss()
                } label: {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(customer.propertyName).foregroundStyle(.primary)
                        if !customer.propertyManagerName.isEmpty {
                            Text(customer.propertyManagerName)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
        }
        .searchable(text: $searchText)
        .navigationTitle("Select Customer")
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") { dismiss() }
            }
        }
        .sheet(isPresented: $isPresentingNewCustomer) {
            NavigationStack {
                CustomerEditView(customer: nil) { newCustomer in
                    onSelect(newCustomer)
                    dismiss()
                }
            }
        }
    }
}
