import Foundation

// The job editor and the future Kanban board share one application record.
public enum ApplicationStatus: String, CaseIterable, Codable, Identifiable, Sendable {
    case interested = "Interested"
    case applied = "Applied"
    case interviewing = "Interviewing"
    case offer = "Offer"
    case closed = "Closed"

    public var id: String { rawValue }
}

public struct JobApplication: Codable, Identifiable, Equatable, Sendable {
    public let id: UUID
    public var company: String
    public var title: String
    public var description: String
    public var jobURL: String?
    public var status: ApplicationStatus
    public var notes: String?
    public let createdAt: Date
    public var updatedAt: Date

    public init(
        id: UUID = UUID(),
        company: String,
        title: String,
        description: String,
        jobURL: String? = nil,
        status: ApplicationStatus = .interested,
        notes: String? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.company = company
        self.title = title
        self.description = description
        self.jobURL = jobURL
        self.status = status
        self.notes = notes
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
