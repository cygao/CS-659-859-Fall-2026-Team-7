#if canImport(SwiftUI)
import SwiftUI
import FieldnoteCore

// Small reusable labels, inputs, and colors shared by add and edit modes.

struct RequiredFieldLabel: View {
    let text: String
    let required: Bool

    var body: some View {
        HStack(spacing: 5) {
            Text(text).font(.system(size: 15, weight: .semibold))
            if required {
                Text("*").foregroundStyle(JobColors.error)
            } else if text == "Job URL" {
                Text("(optional)")
                    .foregroundStyle(JobColors.muted)
                    .fontWeight(.regular)
            }
        }
        .foregroundStyle(JobColors.ink)
    }
}

struct FieldInput: View {
    let label: String
    let placeholder: String
    @Binding var value: String
    let required: Bool
    let error: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            RequiredFieldLabel(text: label, required: required)
            TextField(placeholder, text: $value)
                .textFieldStyle(.plain)
                .font(.system(size: 15))
                .foregroundColor(.black)
                .padding(.horizontal, 15)
                .frame(height: 44)
                .background(JobColors.input)
                .overlay(
                    RoundedRectangle(cornerRadius: 9)
                        .stroke(error == nil ? JobColors.border : JobColors.error)
                )
                .clipShape(RoundedRectangle(cornerRadius: 9))
                .accessibilityLabel(label)
            if let error { ValidationMessage(text: error) }
        }
    }
}

struct ValidationMessage: View {
    let text: String
    var body: some View {
        Label(text, systemImage: "exclamationmark.circle")
            .font(.system(size: 12))
            .foregroundStyle(JobColors.error)
    }
}

struct StatusPill: View {
    let status: ApplicationStatus
    var body: some View {
        Label(status.rawValue, systemImage: "circle.fill")
            .font(.system(size: 13, weight: .semibold))
            .padding(.horizontal, 13)
            .padding(.vertical, 7)
            .foregroundStyle(JobColors.green)
            .background(JobColors.panel)
            .clipShape(Capsule())
    }
}

enum JobColors {
    static let green = Color(red: 0.14, green: 0.37, blue: 0.24)
    static let ink = Color(red: 0.07, green: 0.18, blue: 0.13)
    static let muted = Color(red: 0.33, green: 0.39, blue: 0.35)
    static let page = Color(red: 0.99, green: 0.99, blue: 0.98)
    static let panel = Color(red: 0.92, green: 0.95, blue: 0.91)
    static let input = Color(red: 0.97, green: 0.97, blue: 0.95)
    static let border = Color(red: 0.81, green: 0.83, blue: 0.79)
    static let line = Color(red: 0.85, green: 0.87, blue: 0.83)
    static let error = Color(red: 0.70, green: 0.14, blue: 0.14)
}
#endif
