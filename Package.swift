// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "location",
    platforms: [
        .macOS(.v11)
    ],
    products: [
        .executable(name: "CoreLocationCLI", targets: ["CoreLocationCLI"])
    ],
    targets: [
        .executableTarget(
            name: "CoreLocationCLI",
            linkerSettings: [
                .unsafeFlags([
                    "-Xlinker", "-sectcreate",
                    "-Xlinker", "__TEXT",
                    "-Xlinker", "__info_plist",
                    "-Xlinker", "Info.plist",
                ])
            ]
        )
    ]
)
