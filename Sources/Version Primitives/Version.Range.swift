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
    /// An interval over a versioning kind, with optional inclusive
    /// or exclusive bounds on each side.
    ///
    /// `Version.Range` is generic over any `Comparable` versioning
    /// underlying — `Version.Semantic`, `Version.Calendar`,
    /// `Version.Tools`, or future siblings. The same interval
    /// algebra works across all versioning kinds.
    ///
    /// ## Bound combinations
    ///
    /// | Mathematical form | Constructor |
    /// |---|---|
    /// | (-∞, +∞) | ``Version/Range/all`` |
    /// | [v, v] | ``Version/Range/exact(_:)`` |
    /// | [v, +∞) | ``Version/Range/init(lowerBound:upperBound:)`` with `.inclusive(v)` / `.unbounded` |
    /// | (v, +∞) | `.exclusive(v)` / `.unbounded` |
    /// | (-∞, v) | `.unbounded` / `.exclusive(v)` |
    /// | (-∞, v] | `.unbounded` / `.inclusive(v)` |
    /// | [lo, hi) | `.inclusive(lo)` / `.exclusive(hi)` — the canonical half-open form |
    ///
    /// ## Containment
    ///
    /// ``contains(_:)`` honors each bound's inclusive/exclusive
    /// flavor — semantically equivalent to mathematical interval
    /// containment.
    public struct Range<Underlying: Swift.Sendable & Swift.Hashable & Swift.Comparable>: Swift.Sendable, Swift.Hashable {
        /// The lower bound of the interval.
        public let lowerBound: Bound

        /// The upper bound of the interval.
        public let upperBound: Bound

        /// Creates a range from explicit lower and upper bounds.
        @inlinable
        public init(lowerBound: Bound, upperBound: Bound) {
            self.lowerBound = lowerBound
            self.upperBound = upperBound
        }

        /// The unbounded range matching every value of `Underlying`.
        @inlinable
        public static var all: Self {
            Self(lowerBound: .unbounded, upperBound: .unbounded)
        }

        /// A range matching exactly the given version — closed at
        /// both ends.
        @inlinable
        public static func exact(_ version: Underlying) -> Self {
            Self(lowerBound: .inclusive(version), upperBound: .inclusive(version))
        }

        /// Whether the given version lies within this range.
        @inlinable
        public func contains(_ version: Underlying) -> Swift.Bool {
            switch self.lowerBound {
            case .unbounded: break
            case .inclusive(let lower): if version < lower { return false }
            case .exclusive(let lower): if version <= lower { return false }
            }
            switch self.upperBound {
            case .unbounded: break
            case .inclusive(let upper): if version > upper { return false }
            case .exclusive(let upper): if version >= upper { return false }
            }
            return true
        }
    }
}
