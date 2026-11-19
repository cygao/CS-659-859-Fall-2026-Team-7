#if canImport(SwiftUI)
import SwiftUI
import FieldnoteCore
import FieldnoteJobsUI

@main
struct FieldnoteDemoApp: App {
    var body: some Scene {
        WindowGroup("ResumeTune") {
            DemoShellView()
                .frame(minWidth: 1020, minHeight: 720)
                .preferredColorScheme(.light)
        }
        .defaultSize(width: 1300, height: 850)
    }
}

@MainActor
private final class DemoJobStore: ObservableObject {
    @Published var jobs: [JobApplication] = []
    @Published var loadError: String?
    @Published var notice: String?
    private var repository: (any ApplicationRepository)?

    init() {
        do {
            let localRepository = try LocalJSONApplicationRepository()
            jobs = try localRepository.listApplications()
            repository = localRepository
        } catch {
            loadError = "Unable to load local job data: \(error.localizedDescription)"
        }
    }

    func save(_ job: JobApplication, editing: Bool) throws {
        guard let repository else {
            throw CocoaError(.fileReadUnknown)
        }
        try repository.saveApplication(job)
        jobs = try repository.listApplications()
        notice = editing ? "Changes saved for \(job.company)."
                         : "\(job.company) was added to your applications."
    }
}

private enum DemoRoute: Equatable {
    case applications
    case add
    case edit(UUID)
}

private struct DemoShellView: View {
    @StateObject private var store = DemoJobStore()
    @State private var route: DemoRoute = .applications

    var body: some View {
        HStack(spacing: 0) {
            DemoSidebar(onApplications: { route = .applications })
                .frame(width: 235)
            Divider()

            Group {
                switch route {
                case .applications:
                    applicationsPage
                case .add:
                    JobFormView(
                        onCancel: { route = .applications },
                        onSave: { job in
                            try store.save(job, editing: false)
                            route = .applications
                        }
                    )
                case .edit(let id):
                    if let job = store.jobs.first(where: { $0.id == id }) {
                        JobFormView(
                            existingJob: job,
                            onCancel: { route = .applications },
                            onSave: { updated in
                                try store.save(updated, editing: true)
                                route = .applications
                            }
                        )
                        .id(id)
                    } else {
                        VStack(spacing: 12) {
                            Image(systemName: "briefcase")
                                .font(.system(size: 30))
                            Text("Job not found")
                                .font(.title2.bold())
                            Button("Back to applications") {
                                route = .applications
                            }
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .background(Color(red: 0.99, green: 0.99, blue: 0.98))
    }

    private var applicationsPage: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 23) {
                HStack(alignment: .center) {
                    VStack(alignment: .leading, spacing: 7) {
                        Text("Applications")
                            .font(.system(size: 35, weight: .bold, design: .rounded))
                            .foregroundStyle(Color(red: 0.08, green: 0.20, blue: 0.13))
                        Text("A preview list for testing Add and Edit Jobs.")
                            .font(.system(size: 15))
                            .foregroundStyle(Color(white: 0.32))
                    }
                    Spacer()
                    Button {
                        store.notice = nil
                        route = .add
                    } label: {
                        Label("Add job", systemImage: "plus")
                            .font(.system(size: 15, weight: .semibold))
                            .padding(.horizontal, 19)
                            .padding(.vertical, 12)
                            .foregroundStyle(.white)
                            .background(Color(red: 0.14, green: 0.37, blue: 0.24))
                            .clipShape(RoundedRectangle(cornerRadius: 9))
                    }
                    .buttonStyle(.plain)
                    .disabled(store.loadError != nil)
                }

                Rectangle().fill(Color.gray.opacity(0.23)).frame(height: 1)
                if let loadError = store.loadError {
                    Label(loadError, systemImage: "exclamationmark.triangle")
                        .foregroundStyle(.red)
                        .padding(15)
                }
                if let notice = store.notice {
                    Label(notice, systemImage: "checkmark.circle.fill")
                        .foregroundStyle(Color(red: 0.13, green: 0.38, blue: 0.23))
                        .padding(14)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.green.opacity(0.09))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }

                if store.jobs.isEmpty && store.loadError == nil {
                    VStack(spacing: 12) {
                        Image(systemName: "tray")
                            .font(.system(size: 34))
                        Text("No saved jobs yet")
                            .font(.title3.bold())
                        Text("Select Add job to save your first opportunity.")
                    }
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, minHeight: 230)
                } else {
                    ForEach(store.jobs) { job in
                        HStack(alignment: .center, spacing: 18) {
                            Image(systemName: "briefcase.fill")
                                .font(.system(size: 21))
                                .foregroundStyle(Color(red: 0.18, green: 0.40, blue: 0.27))
                                .frame(width: 48, height: 48)
                                .background(Color.green.opacity(0.1))
                                .clipShape(RoundedRectangle(cornerRadius: 10))

                            VStack(alignment: .leading, spacing: 5) {
                                Text(job.title)
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundStyle(.black)
                                Text(job.company)
                                    .font(.system(size: 14))
                                    .foregroundStyle(Color(white: 0.30))
                            }
                            Spacer()
                            Text(job.status.rawValue)
                                .font(.system(size: 12, weight: .semibold))
                                .padding(.horizontal, 12)
                                .padding(.vertical, 7)
                                .foregroundStyle(Color(red: 0.14, green: 0.37, blue: 0.24))
                                .background(Color.green.opacity(0.12))
                                .clipShape(Capsule())
                            Button("Edit job") {
                                store.notice = nil
                                route = .edit(job.id)
                            }
                            .buttonStyle(.bordered)
                            .foregroundStyle(.black)
                            .controlSize(.large)
                        }
                        .padding(20)
                        .background(.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.gray.opacity(0.2))
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }

                Text("This temporary list is for demonstrating the job editor. " +
                     "The team's Kanban board will replace it during integration.")
                    .font(.system(size: 12))
                    .foregroundStyle(Color(white: 0.38))
                    .padding(.top, 12)
            }
            .frame(maxWidth: 990, alignment: .leading)
            .padding(45)
        }
    }
}

private struct DemoSidebar: View {
    let onApplications: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            HStack(spacing: 12) {
                Image(systemName: "leaf.fill")
                    .font(.system(size: 21))
                    .foregroundStyle(.white)
                    .frame(width: 37, height: 37)
                    .background(Color(red: 0.15, green: 0.40, blue: 0.26))
                    .clipShape(RoundedRectangle(cornerRadius: 10))

                VStack(alignment: .leading, spacing: -3) {
                    Text("Resume")
                    Text("Tune")
                }
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundStyle(.black)
                .fixedSize(horizontal: true, vertical: false)
            }

            .padding(.horizontal, 13)

            VStack(alignment: .leading, spacing: 13) {
                Button(action: onApplications) {
                    Label("Applications", systemImage: "briefcase.fill")
                        .font(.system(size: 15, weight: .semibold))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 15)
                        .padding(.vertical, 13)
                        .background(Color(red: 0.78, green: 0.87, blue: 0.78))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                .buttonStyle(.plain)
                .foregroundStyle(Color(red: 0.09, green: 0.32, blue: 0.18))

                Label("Home", systemImage: "house")
                Label("Saved jobs", systemImage: "bookmark")
                Label("Notes", systemImage: "note.text")
                Label("Settings", systemImage: "gearshape")
            }
            .font(.system(size: 15))
            .foregroundStyle(.black)
            .padding(.horizontal, 6)

            Spacer()
            Text("Add & Edit Jobs\nFeature preview")
                .font(.system(size: 12))
                .foregroundStyle(Color(white: 0.38))
                .padding(.horizontal, 13)
        }
        .padding(.horizontal, 15)
        .padding(.top, 27)
        .padding(.bottom, 24)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(red: 0.95, green: 0.96, blue: 0.93))
    }
}
#else
// Tests can run on Linux; the user interface itself needs macOS + SwiftUI.
@main
struct FieldnoteDemoUnavailable {
    static func main() {
        print("ResumeTune's SwiftUI demo requires macOS 13 or newer.")
    }
}
#endif
