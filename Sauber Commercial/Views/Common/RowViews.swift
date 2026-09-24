import SwiftUI

struct ProposalRow: View {
    var proposal: Proposal

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(proposal.title.isEmpty ? "Untitled Proposal" : proposal.title)
                Text(Formatting.mediumDate.string(from: proposal.createdAt))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 2) {
                Text(Formatting.currencyString(proposal.total))
                    .foregroundStyle(.secondary)
                StatusBadge(text: proposal.status.label, color: color(for: proposal.status))
            }
        }
    }

    private func color(for status: ProposalStatus) -> Color {
        switch status {
        case .draft: return .gray
        case .sent: return .blue
        case .accepted: return .green
        case .declined: return .red
        }
    }
}

struct JobRow: View {
    var job: WorkOrder

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(job.title.isEmpty ? "Untitled Job" : job.title)
                Text(Formatting.mediumDate.string(from: job.scheduledDate))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            StatusBadge(text: job.status.label, color: color(for: job.status))
        }
    }

    private func color(for status: JobStatus) -> Color {
        switch status {
        case .scheduled: return .orange
        case .inProgress: return .blue
        case .completed: return .green
        }
    }
}

struct StatusBadge: View {
    var text: String
    var color: Color

    var body: some View {
        Text(text)
            .font(.caption2.weight(.semibold))
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(color.opacity(0.15))
            .foregroundStyle(color)
            .clipShape(Capsule())
    }
}
