import Foundation
import SwiftData

@Model
final class Customer {
    var id: UUID = UUID()
    var propertyName: String = ""
    var propertyManagerName: String = ""
    var email: String = ""
    var phone: String = ""
    var address: String = ""
    var notes: String = ""
    var createdAt: Date = Date()

    @Relationship(deleteRule: .cascade, inverse: \Proposal.customer)
    var proposals: [Proposal]? = []

    @Relationship(deleteRule: .cascade, inverse: \WorkOrder.customer)
    var jobs: [WorkOrder]? = []

    var allProposals: [Proposal] { proposals ?? [] }
    var allJobs: [WorkOrder] { jobs ?? [] }

    var displayName: String { propertyName }

    init(
        id: UUID = UUID(),
        propertyName: String = "",
        propertyManagerName: String = "",
        email: String = "",
        phone: String = "",
        address: String = "",
        notes: String = "",
        createdAt: Date = Date()
    ) {
        self.id = id
        self.propertyName = propertyName
        self.propertyManagerName = propertyManagerName
        self.email = email
        self.phone = phone
        self.address = address
        self.notes = notes
        self.createdAt = createdAt
    }
}
