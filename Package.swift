// swift-tools-version: 6.3.1

import PackageDescription

// Version Primitives — L1 typed versioning primitives.
//
// Provides typed representations of versioning specifications. At
// v1.0.0, the only inhabitant is Semantic Versioning 2.0.0
// (semver.org), exposed as `Version.Semantic` — a struct that
// validates at construction time per the spec's character-class and
// structure rules.
//
// Per the typed-identifier-naming framework (swift-institute/Research/
// 2026-05-12-typed-identifier-naming-framework.md), the namespace is
// the most-generic English noun — `Version` — rather than a
// spec-flavored `SemVer.*` namespace. Future versioning kinds nest
// additively: `Version.Calendar` (CalVer), `Version.Tools` (SwiftPM
// tools-version subset), etc. The `SemVer` typealias is permitted
// post-v1.0.0 as additive convenience per framework Axiom 1's
// typealias carve-out, but the primary declaration is
// `Version.Semantic`.
//
// Cross-ecosystem reuse is the whole point: NPM bridges, Cargo
// bridges, registry tooling, release automation, and the Swift
// Package Index all consume the same `Version.Semantic` because
// SemVer 2.0.0 is the same spec across ecosystems.
//
// Design Research at swift-institute/Research/
// 2026-05-12-swift-package-and-version-primitives-design.md v1.0.0.

let package = Package(
    name: "swift-version-primitives",
    platforms: [
        .macOS(.v26),
        .iOS(.v26),
        .tvOS(.v26),
        .watchOS(.v26),
        .visionOS(.v26),
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
        .package(path: "../swift-ascii-primitives"),
        .package(path: "../swift-ascii-parser-primitives"),
        .package(path: "../swift-byte-parser-primitives"),
        .package(path: "../swift-carrier-primitives"),
        .package(path: "../swift-ordinal-primitives"),
        .package(path: "../swift-parser-primitives"),
        .package(path: "../swift-serializer-primitives"),
        .package(path: "../swift-tagged-primitives"),
        .package(path: "../swift-text-primitives"),
        .package(path: "../swift-time-primitives"),
    ],
    targets: [
        .target(
            name: "Version Primitives",
            dependencies: [
                .product(name: "ASCII Primitives", package: "swift-ascii-primitives"),
                .product(name: "ASCII Decimal Parser Primitives", package: "swift-ascii-parser-primitives"),
                .product(name: "Byte Parser Primitives", package: "swift-byte-parser-primitives"),
                .product(name: "Carrier Primitives", package: "swift-carrier-primitives"),
                .product(name: "Ordinal Primitives", package: "swift-ordinal-primitives"),
                .product(name: "Parser Primitives", package: "swift-parser-primitives"),
                .product(name: "Serializer Primitives", package: "swift-serializer-primitives"),
                .product(name: "Tagged Primitives", package: "swift-tagged-primitives"),
                .product(name: "Text Primitives", package: "swift-text-primitives"),
                .product(name: "Time Primitives Core", package: "swift-time-primitives"),
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
        .enableExperimentalFeature("LifetimeDependence"),
        .enableExperimentalFeature("Lifetimes"),
        .enableExperimentalFeature("SuppressedAssociatedTypes"),
        .enableUpcomingFeature("InferIsolatedConformances"),
        .enableUpcomingFeature("LifetimeDependence"),
    ]

    let package: [SwiftSetting] = []

    target.swiftSettings = (target.swiftSettings ?? []) + ecosystem + package
}
