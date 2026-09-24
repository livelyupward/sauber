import Foundation
import SwiftData

@Model
final class ChecklistItem {
    var id: UUID = UUID()
    var text: String = ""
    var isDone: Bool = false
    var sortOrder: Int = 0

    var jobReport: JobReport?

    init(
        id: UUID = UUID(),
        text: String = "",
        isDone: Bool = false,
        sortOrder: Int = 0
    ) {
        self.id = id
        self.text = text
        self.isDone = isDone
        self.sortOrder = sortOrder
    }
}
