import XCTest
import Foundation
@testable import FieldnoteCore

final class JobFeatureTests: XCTestCase {
    func testMissingFieldsShowErrors() {
        let input = JobFormInput()
        let errors = input.validationErrors()

        XCTAssertEqual(errors[.company], "Company is required.")
        XCTAssertEqual(errors[.title], "Role title is required.")
        XCTAssertEqual(errors[.description], "Job description is required.")
        XCTAssertNil(errors[.jobURL])
    }

    func testOptionalURLCanBeBlank() {
        let input = JobFormInput(
            company: "Acorn Software",
            title: "Developer",
            description: "Build features"
        )

        XCTAssertTrue(input.validationErrors().isEmpty)
        XCTAssertNil(input.makeApplication().jobURL)
    }

    func testInvalidURLIsRejected() {
        var input = JobFormInput(
            company: "Acorn Software",
            title: "Developer",
            description: "Build features"
        )
        input.jobURL = "careers/acorn"
        XCTAssertNotNil(input.validationErrors()[.jobURL])

        input.jobURL = "https://example.com/jobs"
        XCTAssertNil(input.validationErrors()[.jobURL])
    }

    func testEditPreservesIDAndCreationDate() {
        let created = Date(timeIntervalSince1970: 1_700_000_000)
        let edited = Date(timeIntervalSince1970: 1_700_000_500)
        let job = JobApplication(
            company: "Acorn Software",
            title: "Developer",
            description: "Original description",
            notes: "Keep this note",
            createdAt: created,
            updatedAt: created
        )
        let input = JobFormInput(
            company: "Acorn Software",
            title: "Senior Developer",
            description: "Updated description"
        )
        let result = input.makeApplication(editing: job, now: edited)

        XCTAssertEqual(result.id, job.id)
        XCTAssertEqual(result.createdAt, created)
        XCTAssertEqual(result.updatedAt, edited)
        XCTAssertEqual(result.notes, "Keep this note")
        XCTAssertEqual(result.title, "Senior Developer")
    }

    func testMarkAppliedOnlyChangesTrackingStatus() {
        let input = JobFormInput(
            company: "Acorn Software",
            title: "Developer",
            description: "Build features"
        )
        let job = input.makeApplication(status: .applied)
        XCTAssertEqual(job.status, .applied)
        XCTAssertEqual(job.company, "Acorn Software")
    }

    func testSaveReloadAndUpdateDoesNotDuplicate() throws {
        let directory = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        defer { try? FileManager.default.removeItem(at: directory) }
        let file = directory.appendingPathComponent("jobs.json")
        let repository = try LocalJSONApplicationRepository(
            fileURL: file,
            seedExamples: false
        )
        XCTAssertEqual(try repository.listApplications().count, 0)

        let created = JobFormInput(
            company: "Acorn Software",
            title: "Developer",
            description: "Build features"
        ).makeApplication()
        try repository.saveApplication(created)

        var edited = created
        edited.title = "Senior Developer"
        edited.status = .applied
        try repository.saveApplication(edited)

        let reloaded = try LocalJSONApplicationRepository(fileURL: file)
        let jobs = try reloaded.listApplications()
        XCTAssertEqual(jobs.count, 1)
        XCTAssertEqual(jobs[0].id, created.id)
        XCTAssertEqual(jobs[0].title, "Senior Developer")
        XCTAssertEqual(jobs[0].status, .applied)
    }

    func testFirstLaunchSeedsSyntheticJobs() throws {
        let directory = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        defer { try? FileManager.default.removeItem(at: directory) }
        let file = directory.appendingPathComponent("jobs.json")
        let repository = try LocalJSONApplicationRepository(fileURL: file)

        XCTAssertEqual(try repository.listApplications().count, 2)
    }
}
