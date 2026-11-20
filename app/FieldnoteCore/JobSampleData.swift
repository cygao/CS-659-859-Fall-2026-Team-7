import Foundation

// Synthetic preview records. Only installed on the first app launch.
public enum JobSampleData {
    public static var jobs: [JobApplication] {
        let sampleDate = ISO8601DateFormatter()
            .date(from: "2026-11-01T12:00:00Z") ?? Date(timeIntervalSince1970: 0)

        return [
            JobApplication(
                id: UUID(uuidString: "20000000-0000-4000-8000-000000000011")!,
                company: "Acorn Software",
                title: "Product Manager",
                description: "Build and improve core product experiences for a " +
                    "growing tools platform. Partner with design, engineering, " +
                    "and customer teams to turn problems into useful solutions.",
                jobURL: "https://example.com/acorn-product-manager",
                createdAt: sampleDate,
                updatedAt: sampleDate
            ),
            JobApplication(
                id: UUID(uuidString: "20000000-0000-4000-8000-000000000012")!,
                company: "Cedar Health",
                title: "Product Designer",
                description: "Design accessible product experiences for patients " +
                    "and care teams. Work with product and engineering partners " +
                    "to make complex tasks easier to understand.",
                jobURL: "https://example.com/cedar-product-designer",
                status: .applied,
                createdAt: sampleDate,
                updatedAt: sampleDate
            )
        ]
    }
}
