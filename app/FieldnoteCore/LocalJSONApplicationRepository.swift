import Foundation

// Cameron's future SQLite adapter can implement this same small contract.
public protocol ApplicationRepository {
    func listApplications() throws -> [JobApplication]
    @discardableResult
    func saveApplication(_ application: JobApplication) throws -> JobApplication
}

public final class LocalJSONApplicationRepository: ApplicationRepository {
    public let fileURL: URL

    public init(fileURL: URL? = nil, seedExamples: Bool = true) throws {
        if let fileURL {
            self.fileURL = fileURL
        } else {
            let support = FileManager.default.urls(
                for: .applicationSupportDirectory,
                in: .userDomainMask
            )[0]
            self.fileURL = support
                .appendingPathComponent("Fieldnote", isDirectory: true)
                .appendingPathComponent("jobs-demo.json")
        }

        if !FileManager.default.fileExists(atPath: self.fileURL.path) {
            try write(seedExamples ? JobSampleData.jobs : [])
        }
    }

    public func listApplications() throws -> [JobApplication] {
        let data = try Data(contentsOf: fileURL)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode([JobApplication].self, from: data)
    }

    @discardableResult
    public func saveApplication(_ application: JobApplication) throws -> JobApplication {
        var jobs = try listApplications()
        if let index = jobs.firstIndex(where: { $0.id == application.id }) {
            jobs[index] = application
        } else {
            jobs.append(application)
        }
        try write(jobs)
        return application
    }

    private func write(_ jobs: [JobApplication]) throws {
        try FileManager.default.createDirectory(
            at: fileURL.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(jobs)
        try data.write(to: fileURL, options: .atomic)
    }
}
