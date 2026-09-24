import SwiftUI
import SwiftData

struct CustomerEditView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    var customer: Customer?
    var onCreate: ((Customer) -> Void)?

    @State private var propertyName = ""
    @State private var propertyManagerName = ""
    @State private var email = ""
    @State private var phone = ""
    @State private var address = ""
    @State private var notes = ""

    private var isNew: Bool { customer == nil }

    var body: some View {
        Form {
            Section("Property") {
                TextField("Property Name", text: $propertyName)
                TextField("Property Manager", text: $propertyManagerName)
                TextField("Address", text: $address, axis: .vertical)
                TextField("Phone", text: $phone)
                    .keyboardType(.phonePad)
                TextField("Email", text: $email)
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
            }
            Section("Notes") {
                TextField("Notes", text: $notes, axis: .vertical)
            }
        }
        .navigationTitle(isNew ? "New Customer" : "Edit Customer")
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") { dismiss() }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") { save() }
                    .disabled(propertyName.trimmingCharacters(in: .whitespaces).isEmpty)
            }
        }
        .onAppear {
            guard let customer else { return }
            propertyName = customer.propertyName
            propertyManagerName = customer.propertyManagerName
            email = customer.email
            phone = customer.phone
            address = customer.address
            notes = customer.notes
        }
    }

    private func save() {
        if let customer {
            customer.propertyName = propertyName
            customer.propertyManagerName = propertyManagerName
            customer.email = email
            customer.phone = phone
            customer.address = address
            customer.notes = notes
        } else {
            let newCustomer = Customer(propertyName: propertyName, propertyManagerName: propertyManagerName, email: email, phone: phone, address: address, notes: notes)
            modelContext.insert(newCustomer)
            try? modelContext.save()
            onCreate?(newCustomer)
        }
        try? modelContext.save()
        dismiss()
    }
}
