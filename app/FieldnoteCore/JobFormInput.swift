import Foundation

public enum JobFormField: Hashable {
    case company
    case title
    case description
    case jobURL
}

// Form validation stays outside SwiftUI so it can be tested separately.
public struct JobFormInput {
    public var company: String
    public var title: String
    public var description: String
    public var jobURL: String
    public var status: ApplicationStatus

    public init(
        company: String = "",
        title: String = "",
        description: String = "",
        jobURL: String = "",
        status: ApplicationStatus = .interested
    ) {
        self.company = company
        self.title = title
        self.description = description
        self.jobURL = jobURL
        self.status = status
    }

    public func validationErrors() -> [JobFormField: String] {
        var errors: [JobFormField: String] = [:]

        if company.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            errors[.company] = "Company is required."
        }
        if title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            errors[.title] = "Role title is required."
        }
        if description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            errors[.description] = "Job description is required."
        }

        let trimmedURL = jobURL.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmedURL.isEmpty {
            let parts = URLComponents(string: trimmedURL)
            let validScheme = parts?.scheme == "http" || parts?.scheme == "https"
            let validHost = !(parts?.host ?? "").isEmpty
            if !validScheme || !validHost || trimmedURL.contains(" ") {
                errors[.jobURL] = "Enter a complete http:// or https:// URL."
            }
        }

        return errors
    }

    // Existing IDs and creation dates are preserved to avoid duplicate cards.
    public func makeApplication(
        editing existing: JobApplication? = nil,
        status overrideStatus: ApplicationStatus? = nil,
        now: Date = Date()
    ) -> JobApplication {
        let cleanedURL = jobURL.trimmingCharacters(in: .whitespacesAndNewlines)
        return JobApplication(
            id: existing?.id ?? UUID(),
            company: company.trimmingCharacters(in: .whitespacesAndNewlines),
            title: title.trimmingCharacters(in: .whitespacesAndNewlines),
            description: description.trimmingCharacters(in: .whitespacesAndNewlines),
            jobURL: cleanedURL.isEmpty ? nil : cleanedURL,
            status: overrideStatus ?? status,
            notes: existing?.notes,
            createdAt: existing?.createdAt ?? now,
            updatedAt: now
        )
    }
}
