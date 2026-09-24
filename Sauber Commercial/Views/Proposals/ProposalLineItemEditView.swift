import SwiftUI
import SwiftData

struct ProposalLineItemEditView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \ServiceCatalogItem.sortOrder) private var catalogItems: [ServiceCatalogItem]

    var lineItem: ProposalLineItem?
    var onSave: (String, Decimal, Decimal) -> Void

    @State private var itemDescription = ""
    @State private var quantityText = "1"
    @State private var unitPriceText = ""

    private var isNew: Bool { lineItem == nil }

    var body: some View {
        Form {
            if !catalogItems.isEmpty {
                Section("From Your Services") {
                    ForEach(catalogItems) { item in
                        Button {
                            itemDescription = item.name
                            unitPriceText = NSDecimalNumber(decimal: item.defaultUnitPrice).stringValue
                        } label: {
                            HStack {
                                Text(item.name).foregroundStyle(.primary)
                                Spacer()
                                Text(Formatting.currencyString(item.defaultUnitPrice))
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
            }

            Section("Details") {
                TextField("Description", text: $itemDescription, axis: .vertical)
                TextField("Quantity", text: $quantityText)
                    .keyboardType(.decimalPad)
                TextField("Unit Price", text: $unitPriceText)
                    .keyboardType(.decimalPad)
            }
        }
        .navigationTitle(isNew ? "New Line Item" : "Edit Line Item")
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") { dismiss() }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    let quantity = Decimal(string: quantityText) ?? 1
                    let unitPrice = Decimal(string: unitPriceText) ?? 0
                    onSave(itemDescription, quantity, unitPrice)
                    dismiss()
                }
                .disabled(itemDescription.trimmingCharacters(in: .whitespaces).isEmpty)
            }
        }
        .onAppear {
            guard let lineItem else { return }
            itemDescription = lineItem.itemDescription
            quantityText = NSDecimalNumber(decimal: lineItem.quantity).stringValue
            unitPriceText = NSDecimalNumber(decimal: lineItem.unitPrice).stringValue
        }
    }
}
