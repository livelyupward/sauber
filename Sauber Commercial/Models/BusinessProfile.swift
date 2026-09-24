import Foundation
import SwiftData

@Model
final class BusinessProfile {
    var id: UUID = UUID()
    var businessName: String = ""
    var ownerName: String = ""
    var phone: String = ""
    var email: String = ""
    var address: String = ""
    var website: String = ""
    @Attribute(.externalStorage) var logoData: Data?
    var updatedAt: Date = Date()

    init(
        id: UUID = UUID(),
        businessName: String = "",
        ownerName: String = "",
        phone: String = "",
        email: String = "",
        address: String = "",
        website: String = "",
        logoData: Data? = nil,
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.businessName = businessName
        self.ownerName = ownerName
        self.phone = phone
        self.email = email
        self.address = address
        self.website = website
        self.logoData = logoData
        self.updatedAt = updatedAt
    }
}
