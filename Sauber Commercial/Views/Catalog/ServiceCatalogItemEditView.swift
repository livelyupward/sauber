import SwiftUI
import SwiftData

struct ServiceCatalogItemEditView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    var item: ServiceCatalogItem?

    @State private var name = ""
    @State private var itemDescription = ""
    @State private var unit = "flat"
    @State private var priceText = ""

    private var isNew: Bool { item == nil }

    var body: some View {
        Form {
            Section {
                TextField("Service Name", text: $name)
                TextField("Description (optional)", text: $itemDescription, axis: .vertical)
                TextField("Unit (e.g. flat, sq ft, hour)", text: $unit)
                TextField("Default Price", text: $priceText)
                    .keyboardType(.decimalPad)
            }
        }
        .navigationTitle(isNew ? "New Service" : "Edit Service")
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") { dismiss() }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") { save() }
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
            }
        }
        .onAppear {
            guard let item else { return }
            name = item.name
            itemDescription = item.itemDescription
            unit = item.unit
            priceText = NSDecimalNumber(decimal: item.defaultUnitPrice).stringValue
        }
    }

    private func save() {
        let price = Decimal(string: priceText) ?? 0
        if let item {
            item.name = name
            item.itemDescription = itemDescription
            item.unit = unit
            item.defaultUnitPrice = price
        } else {
            let newItem = ServiceCatalogItem(name: name, itemDescription: itemDescription, unit: unit, defaultUnitPrice: price)
            modelContext.insert(newItem)
        }
        try? modelContext.save()
        dismiss()
    }
}
