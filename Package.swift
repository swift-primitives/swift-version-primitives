// swift-tools-version: 6.4

import PackageDescription

let package = Package(
    name: "swift-version-primitives",
    platforms: [
        .macOS(.v27),
        .iOS(.v27),
        .tvOS(.v27),
        .watchOS(.v27),
        .visionOS(.v27),
    ],
    products: [
        .library(
            name: "Version Primitives",
            targets: ["Version Primitives"]
        ),
        .library(
            name: "Version Primitives Standard Library Integration",
            targets: ["Version Primitives Standard Library Integration"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/swift-primitives/swift-ascii-primitives.git", branch: "main"),
        .package(url: "https://github.com/swift-primitives/swift-ascii-parser-primitives.git", branch: "main"),
        .package(url: "https://github.com/swift-primitives/swift-byte-primitives.git", branch: "main"),
        .package(url: "https://github.com/swift-primitives/swift-byte-parser-primitives.git", branch: "main"),
        .package(url: "https://github.com/swift-primitives/swift-carrier-primitives.git", branch: "main"),
        .package(url: "https://github.com/swift-primitives/swift-ordinal-primitives.git", branch: "main"),
        .package(url: "https://github.com/swift-primitives/swift-parser-primitives.git", branch: "main"),
        .package(url: "https://github.com/swift-primitives/swift-serializer-primitives.git", branch: "main"),
        .package(url: "https://github.com/swift-primitives/swift-tagged-primitives.git", branch: "main"),
        .package(url: "https://github.com/swift-primitives/swift-text-primitives.git", branch: "main"),
        .package(url: "https://github.com/swift-primitives/swift-time-primitives.git", branch: "main"),
    ],
    targets: [
        .target(
            name: "Version Primitives",
            dependencies: [
                .product(name: "ASCII Primitives", package: "swift-ascii-primitives"),
                .product(name: "ASCII Decimal Parser Primitives", package: "swift-ascii-parser-primitives"),
                .product(name: "Byte Primitives Standard Library Integration", package: "swift-byte-primitives"),
                .product(name: "Byte Parser Primitives", package: "swift-byte-parser-primitives"),
                .product(name: "Carrier Primitives", package: "swift-carrier-primitives"),
                .product(name: "Ordinal Primitives", package: "swift-ordinal-primitives"),
                .product(name: "Parser Primitives", package: "swift-parser-primitives"),
                .product(name: "Serializer Primitives", package: "swift-serializer-primitives"),
                .product(name: "Tagged Primitives", package: "swift-tagged-primitives"),
                .product(name: "Text Primitives", package: "swift-text-primitives"),
                .product(name: "Time Primitives", package: "swift-time-primitives"),
            ]
        ),
        .target(
            name: "Version Primitives Standard Library Integration",
            dependencies: [
                "Version Primitives",
            ]
        ),
        .testTarget(
            name: "Version Primitives Tests",
            dependencies: [
                "Version Primitives",
            ],
            path: "Tests/Version Primitives Tests"
        ),
    ],
    swiftLanguageModes: [.v6]
)

for target in package.targets where ![.system, .binary, .plugin, .macro].contains(target.type) {
    let ecosystem: [SwiftSetting] = [
        .strictMemorySafety(),
        .enableUpcomingFeature("ExistentialAny"),
        .enableUpcomingFeature("InternalImportsByDefault"),
        .enableUpcomingFeature("MemberImportVisibility"),
        .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
        .enableExperimentalFeature("Lifetimes"),
        .enableUpcomingFeature("InferIsolatedConformances"),
    ]

    let package: [SwiftSetting] = []

    target.swiftSettings = (target.swiftSettings ?? []) + ecosystem + package
}
