// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "MobileLogger",
    platforms: [
        .iOS(.v18),
        .macOS(.v15),
        .tvOS(.v18),
        .watchOS(.v11),
        .visionOS(.v2)
    ],
    products: [
        .library(name: "MobileLogger", targets: ["MobileLogger"])
    ],
    dependencies: [
        // The redactor of the shared redaction spec (REDACTION-SPEC 2.1, implementation "S").
        .package(url: "https://github.com/muhittincamdali/iOSSecurityTools.git", from: "2.1.2")
    ],
    targets: [
        .target(
            name: "MobileLogger",
            dependencies: [
                .product(name: "iOSSecurityTools", package: "iOSSecurityTools")
            ],
            path: "Sources/MobileLogger"
        ),
        .testTarget(
            name: "MobileLoggerTests",
            dependencies: [
                "MobileLogger",
                .product(name: "iOSSecurityTools", package: "iOSSecurityTools")
            ],
            path: "Tests/MobileLoggerTests"
        )
    ]
)
