// swift-tools-version:5.1
import PackageDescription

let package = Package(
    name: "location",
    platforms: [
        .macOS(.v10_13),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-package-manager", .revision("4d0bab2")),
    ],
    targets: [
        .target(
            name: "CoreLocationCLI",
            dependencies: ["Utility"]),
    ]
)