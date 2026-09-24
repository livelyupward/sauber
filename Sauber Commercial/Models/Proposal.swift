import Foundation
import SwiftData

enum ProposalStatus: String, Codable, CaseIterable, Identifiable {
    case draft
    case sent
    case accepted
    case declined

    var id: String { rawValue }

    var label: String {
        switch self {
        case .draft: return "Draft"
        case .sent: return "Sent"
        case .accepted: return "Accepted"
        case .declined: return "Declined"
        }
    }
}

@Model
final class Proposal {
    var id: UUID = UUID()
    var title: String = ""
    var notes: String = ""
    var statusRawValue: String = ProposalStatus.draft.rawValue
    var createdAt: Date = Date()
    var validUntil: Date?

    @Attribute(.externalStorage) var signatureData: Data?
    var signedName: String = ""
    var signedAt: Date?

    var customer: Customer?
    var resultingWorkOrder: WorkOrder?

    @Relationship(deleteRule: .cascade, inverse: \ProposalLineItem.proposal)
    var lineItems: [ProposalLineItem]? = []

    @Relationship(deleteRule: .cascade, inverse: \PhotoAttachment.proposal)
    var photos: [PhotoAttachment]? = []

    var status: ProposalStatus {
        get { ProposalStatus(rawValue: statusRawValue) ?? .draft }
        set { statusRawValue = newValue.rawValue }
    }

    var allLineItems: [ProposalLineItem] {
        (lineItems ?? []).sorted { $0.sortOrder < $1.sortOrder }
    }

    var allPhotos: [PhotoAttachment] {
        (photos ?? []).sorted { $0.sortOrder < $1.sortOrder }
    }

    var total: Decimal {
        allLineItems.reduce(Decimal(0)) { $0 + $1.lineTotal }
    }

    var isSigned: Bool { signatureData != nil }

    init(
        id: UUID = UUID(),
        title: String = "",
        notes: String = "",
        status: ProposalStatus = .draft,
        createdAt: Date = Date(),
        validUntil: Date? = nil
    ) {
        self.id = id
        self.title = title
        self.notes = notes
        self.statusRawValue = status.rawValue
        self.createdAt = createdAt
        self.validUntil = validUntil
    }
}
