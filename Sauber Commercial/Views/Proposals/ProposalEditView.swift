import SwiftUI
import SwiftData

struct ProposalEditView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    var proposal: Proposal?
    var presetCustomer: Customer?

    @State private var workingProposal: Proposal?
    @State private var createdDraft = false
    @State private var hasValidUntil = false
    @State private var validUntilDate = Date().addingTimeInterval(60 * 60 * 24 * 30)
    @State private var isPresentingCustomerPicker = false
    @State private var editingLineItem: ProposalLineItem?
    @State private var isPresentingNewLineItem = false

    var body: some View {
        Group {
            if let proposal = workingProposal {
                form(for: proposal)
            } else {
                ProgressView()
            }
        }
        .navigationTitle(proposal == nil ? "New Proposal" : "Edit Proposal")
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") { cancel() }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") { save() }
                    .disabled(workingProposal?.customer == nil)
            }
        }
        .onAppear(perform: setup)
        .sheet(isPresented: $isPresentingCustomerPicker) {
            NavigationStack {
                CustomerPickerView { customer in
                    workingProposal?.customer = customer
                }
            }
        }
        .sheet(isPresented: $isPresentingNewLineItem) {
            NavigationStack {
                ProposalLineItemEditView(lineItem: nil) { description, quantity, unitPrice in
                    guard let workingProposal else { return }
                    let sortOrder = (workingProposal.lineItems ?? []).count
                    let item = ProposalLineItem(itemDescription: description, quantity: quantity, unitPrice: unitPrice, sortOrder: sortOrder)
                    item.proposal = workingProposal
                    modelContext.insert(item)
                }
            }
        }
        .sheet(item: $editingLineItem) { item in
            NavigationStack {
                ProposalLineItemEditView(lineItem: item) { description, quantity, unitPrice in
                    item.itemDescription = description
                    item.quantity = quantity
                    item.unitPrice = unitPrice
                }
            }
        }
    }

    @ViewBuilder
    private func form(for proposal: Proposal) -> some View {
        Form {
            Section("Customer") {
                if let customer = proposal.customer {
                    HStack {
                        VStack(alignment: .leading) {
                            Text(customer.propertyName)
                            if !customer.propertyManagerName.isEmpty {
                                Text(customer.propertyManagerName).font(.caption).foregroundStyle(.secondary)
                            }
                        }
                        Spacer()
                        if presetCustomer == nil {
                            Button("Change") { isPresentingCustomerPicker = true }
                        }
                    }
                } else {
                    Button("Select Customer") { isPresentingCustomerPicker = true }
                }
            }

            Section("Proposal") {
                TextField("Title (e.g. Monthly Office Cleaning)", text: Binding(
                    get: { proposal.title },
                    set: { proposal.title = $0 }
                ))
                Toggle("Set expiration date", isOn: $hasValidUntil)
                if hasValidUntil {
                    DatePicker("Valid Until", selection: $validUntilDate, displayedComponents: .date)
                }
            }

            Section {
                ForEach(proposal.allLineItems) { item in
                    Button {
                        editingLineItem = item
                    } label: {
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(item.itemDescription).foregroundStyle(.primary)
                                Text("\(Formatting.quantityString(item.quantity)) × \(Formatting.currencyString(item.unitPrice))")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            Text(Formatting.currencyString(item.lineTotal))
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .onDelete { offsets in
                    let items = proposal.allLineItems
                    for index in offsets {
                        modelContext.delete(items[index])
                    }
                }

                HStack {
                    Text("Total")
                        .fontWeight(.semibold)
                    Spacer()
                    Text(Formatting.currencyString(proposal.total))
                        .fontWeight(.semibold)
                }
            } header: {
                HStack {
                    Text("Line Items")
                    Spacer()
                    Button { isPresentingNewLineItem = true } label: { Image(systemName: "plus.circle") }
                }
            }

            Section("Photos") {
                PhotoPickerGridView(
                    photos: proposal.allPhotos,
                    onAdd: { data in
                        let sortOrder = (proposal.photos ?? []).count
                        let attachment = PhotoAttachment(imageData: data, role: .general, sortOrder: sortOrder)
                        attachment.proposal = proposal
                        modelContext.insert(attachment)
                    },
                    onDelete: { photo in
                        modelContext.delete(photo)
                    }
                )
            }

            Section("Notes") {
                TextField("Notes for this proposal", text: Binding(
                    get: { proposal.notes },
                    set: { proposal.notes = $0 }
                ), axis: .vertical)
            }
        }
    }

    private func setup() {
        guard workingProposal == nil else { return }
        if let proposal {
            workingProposal = proposal
            hasValidUntil = proposal.validUntil != nil
            if let validUntil = proposal.validUntil {
                validUntilDate = validUntil
            }
        } else {
            let newProposal = Proposal()
            newProposal.customer = presetCustomer
            modelContext.insert(newProposal)
            workingProposal = newProposal
            createdDraft = true
        }
    }

    private func save() {
        workingProposal?.validUntil = hasValidUntil ? validUntilDate : nil
        try? modelContext.save()
        dismiss()
    }

    private func cancel() {
        if createdDraft, let workingProposal {
            modelContext.delete(workingProposal)
        }
        dismiss()
    }
}
