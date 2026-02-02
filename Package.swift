// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "MobileLogger",
    platforms: [
        .iOS(.v15),
        .macOS(.v13),
        .tvOS(.v15),
        .watchOS(.v8)
    ],
    products: [
        .library(
            name: "MobileLogger",
            targets: ["MobileLogger"]
        )
    ],
    targets: [
        .target(
            name: "MobileLogger",
            path: "Sources/MobileLogger"
        ),
        .testTarget(
            name: "MobileLoggerTests",
            dependencies: ["MobileLogger"],
            path: "Tests/MobileLoggerTests"
        )
    ]
)
