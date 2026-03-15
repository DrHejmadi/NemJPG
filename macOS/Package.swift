// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "NemJPG",
    platforms: [.macOS(.v13)],
    targets: [
        .executableTarget(
            name: "NemJPG",
            path: "Sources",
            resources: [
                .process("Resources")
            ]
        )
    ]
)
