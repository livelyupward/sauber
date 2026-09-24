import Foundation
import SwiftData

enum PhotoRole: String, Codable {
    case general
    case before
    case after
}

@Model
final class PhotoAttachment {
    var id: UUID = UUID()
    @Attribute(.externalStorage) var imageData: Data = Data()
    var caption: String = ""
    var roleRawValue: String = PhotoRole.general.rawValue
    var createdAt: Date = Date()
    var sortOrder: Int = 0

    var proposal: Proposal?
    var jobReport: JobReport?

    var role: PhotoRole {
        get { PhotoRole(rawValue: roleRawValue) ?? .general }
        set { roleRawValue = newValue.rawValue }
    }

    init(
        id: UUID = UUID(),
        imageData: Data = Data(),
        caption: String = "",
        role: PhotoRole = .general,
        createdAt: Date = Date(),
        sortOrder: Int = 0
    ) {
        self.id = id
        self.imageData = imageData
        self.caption = caption
        self.roleRawValue = role.rawValue
        self.createdAt = createdAt
        self.sortOrder = sortOrder
    }
}
