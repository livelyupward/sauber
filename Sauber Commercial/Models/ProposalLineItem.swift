import Foundation
import SwiftData

@Model
final class ProposalLineItem {
    var id: UUID = UUID()
    var itemDescription: String = ""
    var quantity: Decimal = 1
    var unitPrice: Decimal = 0
    var sortOrder: Int = 0

    var proposal: Proposal?

    var lineTotal: Decimal { quantity * unitPrice }

    init(
        id: UUID = UUID(),
        itemDescription: String = "",
        quantity: Decimal = 1,
        unitPrice: Decimal = 0,
        sortOrder: Int = 0
    ) {
        self.id = id
        self.itemDescription = itemDescription
        self.quantity = quantity
        self.unitPrice = unitPrice
        self.sortOrder = sortOrder
    }
}
