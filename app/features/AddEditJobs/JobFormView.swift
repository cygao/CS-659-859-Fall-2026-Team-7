#if canImport(SwiftUI)
import SwiftUI
import FieldnoteCore

// Reusable form: the final Kanban board can present this view directly.
public struct JobFormView: View {
    private let existingJob: JobApplication?
    private let onCancel: () -> Void
    private let onSave: @MainActor (JobApplication) throws -> Void

    @State private var company: String
    @State private var title: String
    @State private var description: String
    @State private var jobURL: String
    @State private var status: ApplicationStatus
    @State private var attemptedSave = false
    @State private var isSaving = false
    @State private var saveError: String?

    public init(
        existingJob: JobApplication? = nil,
        onCancel: @escaping () -> Void,
        onSave: @escaping @MainActor (JobApplication) throws -> Void
    ) {
        self.existingJob = existingJob
        self.onCancel = onCancel
        self.onSave = onSave
        _company = State(initialValue: existingJob?.company ?? "")
        _title = State(initialValue: existingJob?.title ?? "")
        _description = State(initialValue: existingJob?.description ?? "")
        _jobURL = State(initialValue: existingJob?.jobURL ?? "")
        _status = State(initialValue: existingJob?.status ?? .interested)
    }

    private var isEditing: Bool { existingJob != nil }

    private var formInput: JobFormInput {
        JobFormInput(
            company: company,
            title: title,
            description: description,
            jobURL: jobURL,
            status: status
        )
    }

    private var errors: [JobFormField: String] {
        attemptedSave ? formInput.validationErrors() : [:]
    }

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 26) {
                breadcrumb
                titleArea
                Rectangle().fill(JobColors.line).frame(height: 1)

                HStack(alignment: .top, spacing: 34) {
                    formFields
                        .frame(maxWidth: .infinity, alignment: .leading)
                    if isEditing {
                        trackingCard
                            .frame(width: 280)
                    }
                }

                Rectangle().fill(JobColors.line).frame(height: 1)
                bottomActions
            }
            .frame(maxWidth: 1160, alignment: .leading)
            .padding(.horizontal, 48)
            .padding(.vertical, 36)
        }
        .background(JobColors.page)
    }

    private var breadcrumb: some View {
        Button(action: onCancel) {
            HStack(spacing: 9) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 13, weight: .bold))
                Text("Applications")
                    .font(.system(size: 15, weight: .medium))
                if isEditing {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 11))
                        .foregroundStyle(JobColors.muted)
                    Text("Edit job")
                        .foregroundStyle(JobColors.muted)
                }
            }
            .foregroundStyle(JobColors.green)
        }
        .buttonStyle(.plain)
        .accessibilityHint("Return to the applications list")
    }

    private var titleArea: some View {
        VStack(alignment: .leading, spacing: 9) {
            HStack(spacing: 18) {
                Text(isEditing ? "Edit job" : "Add job")
                    .font(.system(size: 38, weight: .bold, design: .rounded))
                    .foregroundStyle(JobColors.ink)
                if isEditing {
                    StatusPill(status: status)
                }
            }
            Text(isEditing
                 ? "Update your saved job details and track its progress."
                 : "Save the details now to support later resume suggestions.")
                .font(.system(size: 16))
                .foregroundStyle(JobColors.muted)
        }
    }

    private var formFields: some View {
        VStack(alignment: .leading, spacing: 23) {
            FieldInput(
                label: "Company", placeholder: "e.g., Acorn Software",
                value: $company, required: true, error: errors[.company]
            )
            FieldInput(
                label: "Role title", placeholder: "e.g., Product Manager",
                value: $title, required: true, error: errors[.title]
            )

            VStack(alignment: .leading, spacing: 8) {
                RequiredFieldLabel(text: "Job description", required: true)
                TextEditor(text: $description)
                    .font(.system(size: 15))
                    .foregroundColor(.black)
                    .scrollContentBackground(.hidden)
                    .padding(9)
                    .frame(height: 190)
                    .background(JobColors.input)
                    .overlay(
                        RoundedRectangle(cornerRadius: 9)
                            .stroke(errors[.description] == nil
                                    ? JobColors.border : JobColors.error, lineWidth: 1)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 9))
                    .accessibilityLabel("Job description")
                if description.isEmpty && !attemptedSave {
                    Text("Paste the job posting or write its main responsibilities.")
                        .font(.system(size: 12))
                        .foregroundStyle(JobColors.muted)
                }
                if let error = errors[.description] {
                    ValidationMessage(text: error)
                }
            }

            FieldInput(
                label: "Job URL", placeholder: "https://company.com/careers/...",
                value: $jobURL, required: false, error: errors[.jobURL]
            )

            VStack(alignment: .leading, spacing: 9) {
                RequiredFieldLabel(text: "Application status", required: false)
                Picker("Application status", selection: $status) {
                    ForEach(ApplicationStatus.allCases) { stage in
                        Text(stage.rawValue).tag(stage)
                    }
                }
                .labelsHidden()
                .pickerStyle(.menu)
                .controlSize(.large)
                .frame(maxWidth: .infinity, alignment: .leading)
                Text("New jobs start as Interested. Change this when your progress changes.")
                    .font(.system(size: 12))
                    .foregroundStyle(JobColors.muted)
            }

            if let saveError {
                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: "exclamationmark.triangle.fill")
                    Text("Could not save your changes: \(saveError)")
                }
                .font(.system(size: 13))
                .foregroundStyle(JobColors.error)
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(JobColors.error.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
        }
    }

    private var trackingCard: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("Tracking only")
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(JobColors.ink)
            Text("Update your application status in ResumeTune. " +
                 "This app does not submit applications.")
                .font(.system(size: 14))
                .foregroundStyle(JobColors.muted)
                .fixedSize(horizontal: false, vertical: true)

            if status == .interested {
                Button {
                    saveJob(markAsApplied: true)
                } label: {
                    HStack(spacing: 9) {
                        if isSaving {
                            ProgressView().controlSize(.small)
                        } else {
                            Image(systemName: "checkmark")
                        }
                        Text("Mark as applied")
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                }
                .buttonStyle(.plain)
                .foregroundStyle(.white)
                .background(JobColors.green)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .disabled(isSaving)
                Text("This also saves your current edits.")
                    .font(.system(size: 12))
                    .foregroundStyle(JobColors.muted)
            } else {
                HStack(spacing: 7) {
                    Image(systemName: "checkmark.circle.fill")
                    Text("Current status: \(status.rawValue)")
                }
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(JobColors.green)
            }

            Label("No job application is submitted for you.", systemImage: "info.circle")
                .font(.system(size: 12))
                .foregroundStyle(JobColors.muted)
        }
        .padding(22)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(JobColors.panel)
        .overlay(RoundedRectangle(cornerRadius: 13).stroke(JobColors.border))
        .clipShape(RoundedRectangle(cornerRadius: 13))
    }

    private var bottomActions: some View {
        HStack(spacing: 13) {
            Button {
                saveJob(markAsApplied: false)
            } label: {
                HStack(spacing: 8) {
                    if isSaving { ProgressView().controlSize(.small) }
                    Text(isSaving ? "Saving…" : (isEditing ? "Save changes" : "Save job"))
                }
                .font(.system(size: 15, weight: .semibold))
                .frame(minWidth: 128)
                .padding(.vertical, 12)
                .padding(.horizontal, 17)
            }
            .buttonStyle(.plain)
            .foregroundStyle(.white)
            .background(JobColors.green)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .disabled(isSaving)
            .keyboardShortcut(.return, modifiers: .command)

            Button("Cancel", action: onCancel)
                .buttonStyle(.plain)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(JobColors.ink)
                .padding(.vertical, 12)
                .padding(.horizontal, 22)
                .background(JobColors.panel)
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(JobColors.border))
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .disabled(isSaving)

            Spacer(minLength: 15)
            Text("This app does not submit applications")
                .font(.system(size: 12))
                .foregroundStyle(JobColors.muted)
        }
    }

    private func saveJob(markAsApplied: Bool) {
        attemptedSave = true
        saveError = nil
        let input = formInput
        guard input.validationErrors().isEmpty else { return }

        isSaving = true
        Task { @MainActor in
            defer { isSaving = false }
            do {
                let job = input.makeApplication(
                    editing: existingJob,
                    status: markAsApplied ? .applied : nil
                )
                try onSave(job)
            } catch {
                saveError = error.localizedDescription
            }
        }
    }
}

#endif
