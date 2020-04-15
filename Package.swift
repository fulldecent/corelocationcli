// swift-tools-version:5.1
import PackageDescription

let package = Package(
    name: "location",
    platforms: [
        .macOS(.v10_14),
    ],
    targets: [
        .target(name: "CoreLocationCLI")
    ]
)