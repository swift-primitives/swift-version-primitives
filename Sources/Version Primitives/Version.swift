// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-version-primitives open source project
//
// Copyright (c) 2026 Coen ten Thije Boonkkamp and the swift-version-primitives project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// ===----------------------------------------------------------------------===//

/// Namespace for versioning primitives.
///
/// `Version` is the generic noun for the versioning domain. The
/// namespace hosts typed representations of specific versioning
/// schemes — at v1.0.0, `Version.Semantic` (Semantic Versioning
/// 2.0.0 per https://semver.org/).
///
/// Per the typed-identifier-naming framework, the namespace is
/// generic rather than spec-flavored — `Version` not `SemVer` —
/// so cross-ecosystem tooling (registry analyzers, dependency
/// tooling, manifest generators, NPM/Cargo bridges) can adopt the
/// type without importing a consumer-flavored surface.
///
/// Future siblings (additive per framework Axiom 3) MAY include
/// `Version.Calendar` (CalVer — `YYYY.MM.DD` and variants),
/// `Version.Tools` (SwiftPM tools-version, a SemVer subset per
/// SE-0152), `Version.Date` (date-keyed versioning).
public enum Version: Swift.Sendable {}
