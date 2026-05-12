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

extension Version.Range where Underlying == Version.Semantic {
    /// A range from `version` (inclusive) up to but not including
    /// the next MAJOR version — the caret-style (`^v`) semantic
    /// version range used by SwiftPM and npm.
    ///
    /// Equivalent to `[version, next-major)` where the next major
    /// is `MAJOR+1.0.0`.
    @inlinable
    public static func upToNextMajor(from version: Version.Semantic) -> Self {
        let nextMajor = Version.Semantic(
            major: .init(version.major.underlying + 1),
            minor: 0,
            patch: 0
        )
        return Self(lowerBound: .inclusive(version), upperBound: .exclusive(nextMajor))
    }

    /// A range from `version` (inclusive) up to but not including
    /// the next MINOR version — the tilde-style (`~v`) semantic
    /// version range.
    ///
    /// Equivalent to `[version, next-minor)` where the next minor
    /// is `MAJOR.MINOR+1.0`.
    @inlinable
    public static func upToNextMinor(from version: Version.Semantic) -> Self {
        let nextMinor = Version.Semantic(
            major: .init(version.major.underlying),
            minor: .init(version.minor.underlying + 1),
            patch: 0
        )
        return Self(lowerBound: .inclusive(version), upperBound: .exclusive(nextMinor))
    }
}
