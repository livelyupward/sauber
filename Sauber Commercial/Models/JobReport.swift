import Foundation
import SwiftData

@Model
final class JobReport {
    var id: UUID = UUID()
    var notes: String = ""
    var technicianName: String = ""
    var createdAt: Date = Date()

    @Attribute(.externalStorage) var signatureData: Data?
    var signedName: String = ""
    var signedAt: Date?

    var job: WorkOrder?

    @Relationship(deleteRule: .cascade, inverse: \ChecklistItem.jobReport)
    var checklistItems: [ChecklistItem]? = []

    @Relationship(deleteRule: .cascade, inverse: \PhotoAttachment.jobReport)
    var photos: [PhotoAttachment]? = []

    var allChecklistItems: [ChecklistItem] {
        (checklistItems ?? []).sorted { $0.sortOrder < $1.sortOrder }
    }

    var beforePhotos: [PhotoAttachment] {
        (photos ?? []).filter { $0.role == .before }.sorted { $0.sortOrder < $1.sortOrder }
    }

    var afterPhotos: [PhotoAttachment] {
        (photos ?? []).filter { $0.role == .after }.sorted { $0.sortOrder < $1.sortOrder }
    }

    var generalPhotos: [PhotoAttachment] {
        (photos ?? []).filter { $0.role == .general }.sorted { $0.sortOrder < $1.sortOrder }
    }

    var isSigned: Bool { signatureData != nil }

    init(
        id: UUID = UUID(),
        notes: String = "",
        technicianName: String = "",
        createdAt: Date = Date()
    ) {
        self.id = id
        self.notes = notes
        self.technicianName = technicianName
        self.createdAt = createdAt
    }
}
