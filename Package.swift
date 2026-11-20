// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "ResumeTune",
    platforms: [.macOS(.v13)],
    products: [
        .library(name: "FieldnoteCore", targets: ["FieldnoteCore"]),
        .library(name: "FieldnoteJobsUI", targets: ["FieldnoteJobsUI"]),
        .executable(name: "FieldnoteDemo", targets: ["FieldnoteDemo"])
    ],
    targets: [
        .target(name: "FieldnoteCore", path: "app/FieldnoteCore"),
        .target(
            name: "FieldnoteJobsUI",
            dependencies: ["FieldnoteCore"],
            path: "app/features/AddEditJobs",
            exclude: ["README.md"]
        ),
        .executableTarget(
            name: "FieldnoteDemo",
            dependencies: ["FieldnoteCore", "FieldnoteJobsUI"],
            path: "app/FieldnoteDemo"
        ),
        .testTarget(
            name: "FieldnoteCoreTests",
            dependencies: ["FieldnoteCore"],
            path: "tests/FieldnoteCoreTests"
        )
    ]
)
