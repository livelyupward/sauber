import SwiftUI
import SwiftData

struct ProposalDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var proposal: Proposal
    @Query private var profiles: [BusinessProfile]

    @State private var isEditing = false
    @State private var isPresentingSignature = false
    @State private var isPresentingPreview = false
    @State private var generatedPDFData: Data?
    @State private var createdWorkOrder: WorkOrder?
    @State private var navigateToWorkOrder = false

    private var businessProfile: BusinessProfile? { profiles.first }

    var body: some View {
        List {
            Section {
                LabeledContent("Customer", value: proposal.customer?.propertyName ?? "—")
                if let managerName = proposal.customer?.propertyManagerName, !managerName.isEmpty {
                    LabeledContent("Property Manager", value: managerName)
                }
                if let address = proposal.customer?.address, !address.isEmpty {
                    LabeledContent("Address", value: address)
                }
                if let phone = proposal.customer?.phone, !phone.isEmpty {
                    LabeledContent("Phone Number", value: phone)
                }
                LabeledContent("Created", value: Formatting.mediumDate.string(from: proposal.createdAt))
                if let validUntil = proposal.validUntil {
                    LabeledContent("Valid Until", value: Formatting.mediumDate.string(from: validUntil))
                }
                Picker("Status", selection: Binding(
                    get: { proposal.status },
                    set: { proposal.status = $0 }
                )) {
                    ForEach(ProposalStatus.allCases) { status in
                        Text(status.label).tag(status)
                    }
                }
            }

            if !proposal.allLineItems.isEmpty {
                Section("Line Items") {
                    ForEach(proposal.allLineItems) { item in
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(item.itemDescription)
                                Text("\(Formatting.quantityString(item.quantity)) × \(Formatting.currencyString(item.unitPrice))")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            Text(Formatting.currencyString(item.lineTotal))
                        }
                    }
                    HStack {
                        Text("Total").fontWeight(.semibold)
                        Spacer()
                        Text(Formatting.currencyString(proposal.total)).fontWeight(.semibold)
                    }
                }
            }

            if !proposal.notes.isEmpty {
                Section("Notes") {
                    Text(proposal.notes)
                }
            }

            if !proposal.allPhotos.isEmpty {
                Section("Photos") {
                    ScrollView(.horizontal) {
                        HStack {
                            ForEach(proposal.allPhotos) { photo in
                                if let uiImage = UIImage(data: photo.imageData) {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 90, height: 90)
                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                }
                            }
                        }
                    }
                }
            }

            Section("Approval") {
                if proposal.isSigned {
                    LabeledContent("Signed by", value: proposal.signedName)
                    if let signedAt = proposal.signedAt {
                        LabeledContent("Signed on", value: Formatting.mediumDate.string(from: signedAt))
                    }
                } else {
                    Button("Capture Customer Signature") { isPresentingSignature = true }
                }
            }

            Section {
                Button {
                    generatedPDFData = ProposalPDFGenerator.generate(proposal: proposal, businessProfile: businessProfile)
                    isPresentingPreview = true
                } label: {
                    Label("Preview / Send PDF", systemImage: "doc.richtext")
                }

                if proposal.status == .accepted {
                    Button {
                        startWorkOrder()
                    } label: {
                        Label("Start Job", systemImage: "hammer")
                    }
                }
            }
        }
        .navigationTitle(proposal.title.isEmpty ? "Proposal" : proposal.title)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Edit") { isEditing = true }
            }
        }
        .sheet(isPresented: $isEditing) {
            NavigationStack {
                ProposalEditView(proposal: proposal, presetCustomer: proposal.customer)
            }
        }
        .sheet(isPresented: $isPresentingSignature) {
            SignatureCaptureSheet(title: "Accept Proposal") { data, name in
                proposal.signatureData = data
                proposal.signedName = name
                proposal.signedAt = Date()
                proposal.status = .accepted
                try? modelContext.save()
            }
        }
        .sheet(isPresented: $isPresentingPreview) {
            if let generatedPDFData {
                PDFPreviewSheet(
                    title: "Proposal",
                    pdfData: generatedPDFData,
                    fileName: "\(proposal.title.isEmpty ? "Proposal" : proposal.title).pdf",
                    recipientEmail: proposal.customer?.email ?? "",
                    emailSubject: "Proposal from \(businessProfile?.businessName ?? "us")",
                    emailBody: "Hi \(proposal.customer?.propertyManagerName ?? ""),\n\nPlease find our proposal for \(proposal.customer?.propertyName ?? "your property") attached.\n\nThanks,\n\(businessProfile?.ownerName ?? "")"
                ) {
                    if proposal.status == .draft {
                        proposal.status = .sent
                        try? modelContext.save()
                    }
                }
            }
        }
        .navigationDestination(isPresented: $navigateToWorkOrder) {
            if let createdWorkOrder {
                JobDetailView(job: createdWorkOrder)
            }
        }
    }

    private func startWorkOrder() {
        let workOrder = WorkOrder(title: proposal.title.isEmpty ? "Job" : proposal.title)
        workOrder.customer = proposal.customer
        workOrder.originatingProposal = proposal
        modelContext.insert(workOrder)
        try? modelContext.save()
        createdWorkOrder = workOrder
        navigateToWorkOrder = true
    }
}
