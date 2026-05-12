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

extension Version {
    /// An algebraic set of versions, built from the five constructors
    /// `.empty`, `.any`, `.exact`, `.range`, and `.union`.
    ///
    /// Mirrors the shape of SwiftPM's internal `VersionSetSpecifier`
    /// — the canonical Swift-side model for "which versions does
    /// this dependency require?" — but is generic over any
    /// `Comparable` versioning kind (`Version.Semantic`,
    /// `Version.Calendar`, `Version.Tools`, future siblings).
    ///
    /// ## Cases
    ///
    /// | Case | Membership |
    /// |---|---|
    /// | ``empty`` | no version |
    /// | ``any`` | every version |
    /// | ``exact(_:)`` | exactly the given version |
    /// | ``range(_:)`` | every version inside the given ``Version/Range`` |
    /// | ``union(_:)`` | every version inside any of the contained sets |
    ///
    /// Intersection / complement are not modeled as constructors —
    /// they fall out of compositions of the existing five and are
    /// best derived per consumer demand.
    public indirect enum Set<Underlying: Swift.Sendable & Swift.Hashable & Swift.Comparable>: Swift.Sendable, Swift.Hashable {
        /// The empty set — matches no version.
        case empty

        /// The universal set — matches every version of `Underlying`.
        case any

        /// A singleton set — matches exactly the given version.
        case exact(Underlying)

        /// A contiguous interval — matches every version inside the
        /// supplied ``Version/Range``.
        case range(Version.Range<Underlying>)

        /// A disjunctive union — matches every version inside any of
        /// the supplied sets.
        case union([Version.Set<Underlying>])
    }
}

extension Version.Set {
    /// Whether the given version is a member of this set.
    @inlinable
    public func contains(_ version: Underlying) -> Swift.Bool {
        switch self {
        case .empty:
            return false

        case .any:
            return true

        case .exact(let target):
            return version == target

        case .range(let interval):
            return interval.contains(version)

        case .union(let members):
            for member in members where member.contains(version) {
                return true
            }
            return false
        }
    }
}
