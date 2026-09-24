import Foundation
import SwiftData

enum JobStatus: String, Codable, CaseIterable, Identifiable {
    case scheduled
    case inProgress
    case completed

    var id: String { rawValue }

    var label: String {
        switch self {
        case .scheduled: return "Scheduled"
        case .inProgress: return "In Progress"
        case .completed: return "Completed"
        }
    }
}

@Model
final class WorkOrder {
    var id: UUID = UUID()
    var title: String = ""
    var jobDescription: String = ""
    var statusRawValue: String = JobStatus.scheduled.rawValue
    var scheduledDate: Date = Date()
    var createdAt: Date = Date()

    var customer: Customer?

    @Relationship(inverse: \Proposal.resultingWorkOrder)
    var originatingProposal: Proposal?

    @Relationship(deleteRule: .cascade, inverse: \JobReport.job)
    var reports: [JobReport]? = []

    var status: JobStatus {
        get { JobStatus(rawValue: statusRawValue) ?? .scheduled }
        set { statusRawValue = newValue.rawValue }
    }

    var allReports: [JobReport] {
        (reports ?? []).sorted { $0.createdAt > $1.createdAt }
    }

    init(
        id: UUID = UUID(),
        title: String = "",
        jobDescription: String = "",
        status: JobStatus = .scheduled,
        scheduledDate: Date = Date(),
        createdAt: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.jobDescription = jobDescription
        self.statusRawValue = status.rawValue
        self.scheduledDate = scheduledDate
        self.createdAt = createdAt
    }
}
