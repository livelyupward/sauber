import Foundation
import SwiftData

@Model
final class ServiceCatalogItem {
    var id: UUID = UUID()
    var name: String = ""
    var itemDescription: String = ""
    var unit: String = "flat"
    var defaultUnitPrice: Decimal = 0
    var sortOrder: Int = 0
    var createdAt: Date = Date()

    init(
        id: UUID = UUID(),
        name: String = "",
        itemDescription: String = "",
        unit: String = "flat",
        defaultUnitPrice: Decimal = 0,
        sortOrder: Int = 0,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.itemDescription = itemDescription
        self.unit = unit
        self.defaultUnitPrice = defaultUnitPrice
        self.sortOrder = sortOrder
        self.createdAt = createdAt
    }
}
