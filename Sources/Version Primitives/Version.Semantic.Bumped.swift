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

extension Version.Semantic {
    /// Nested accessor producing the next version along each
    /// SemVer 2.0.0 §6/§7/§8 axis.
    ///
    /// Reach via the ``Version/Semantic/bumped`` property; each
    /// component access returns a NEW ``Version/Semantic``:
    ///
    /// ```swift
    /// let v = Version.Semantic(major: 1, minor: 2, patch: 3)
    /// v.bumped.major   // 2.0.0
    /// v.bumped.minor   // 1.3.0
    /// v.bumped.patch   // 1.2.4
    /// ```
    ///
    /// Pre-release and build-metadata identifiers are NOT carried
    /// over — bumping conceptually starts a new stable release
    /// branch.
    ///
    /// The nested-accessor shape (`.bumped.major` rather than
    /// `.bumpedMajor()`) follows the institute's
    /// `[API-NAME-002]` rule against compound method/property
    /// names.
    public struct Bumped: Swift.Sendable {
        @usableFromInline
        let base: Version.Semantic

        @inlinable
        package init(_ base: Version.Semantic) {
            self.base = base
        }
    }

    /// The nested-accessor entry point for bumping operations —
    /// `version.bumped.major / .minor / .patch` produce new
    /// versions on the three SemVer axes.
    @inlinable
    public var bumped: Bumped {
        Bumped(self)
    }
}

extension Version.Semantic.Bumped {
    /// The next major-bumped version (`MAJOR+1.0.0`) per SemVer
    /// 2.0.0 §8.
    @inlinable
    public var major: Version.Semantic {
        Version.Semantic(
            major: .init(self.base.major.underlying + 1),
            minor: 0,
            patch: 0
        )
    }

    /// The next minor-bumped version (`MAJOR.MINOR+1.0`) per
    /// SemVer 2.0.0 §7.
    @inlinable
    public var minor: Version.Semantic {
        Version.Semantic(
            major: self.base.major,
            minor: .init(self.base.minor.underlying + 1),
            patch: 0
        )
    }

    /// The next patch-bumped version (`MAJOR.MINOR.PATCH+1`)
    /// per SemVer 2.0.0 §6.
    @inlinable
    public var patch: Version.Semantic {
        Version.Semantic(
            major: self.base.major,
            minor: self.base.minor,
            patch: .init(self.base.patch.underlying + 1)
        )
    }
}
