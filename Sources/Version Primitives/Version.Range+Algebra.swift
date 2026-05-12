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

extension Version.Range {
    /// Whether this range contains zero versions.
    ///
    /// A bounded range is empty when its lower bound is greater than
    /// its upper bound, or when the bounds are equal and either side
    /// is exclusive (so the boundary value is excluded by both).
    /// Unbounded ranges are never empty.
    @inlinable
    public var isEmpty: Swift.Bool {
        switch (self.lowerBound, self.upperBound) {
        case (.unbounded, _), (_, .unbounded):
            return false

        case (.inclusive(let lo), .inclusive(let hi)):
            return lo > hi

        case (.inclusive(let lo), .exclusive(let hi)),
            (.exclusive(let lo), .inclusive(let hi)):
            return lo >= hi

        case (.exclusive(let lo), .exclusive(let hi)):
            return lo >= hi
        }
    }

    /// The intersection of this range with `other`.
    ///
    /// The result contains exactly the versions in BOTH input
    /// ranges. May be empty; check ``isEmpty`` if that matters.
    @inlinable
    public func intersection(_ other: Self) -> Self {
        Self(
            lowerBound: Self.maxLowerBound(self.lowerBound, other.lowerBound),
            upperBound: Self.minUpperBound(self.upperBound, other.upperBound)
        )
    }

    /// Whether this range and `other` share at least one version.
    ///
    /// Equivalent to `!self.intersection(other).isEmpty` but
    /// signals intent more clearly at call sites. The
    /// `is_disjoint` lint rule targets `Swift.Set`'s
    /// `intersection(_:).isEmpty` shape — it does not apply to
    /// `Version.Range.intersection`, whose semantics are interval
    /// algebra, not set-element intersection.
    @inlinable
    public func overlaps(_ other: Self) -> Swift.Bool {
        // swiftlint:disable:next is_disjoint
        !self.intersection(other).isEmpty
    }

    /// Whether every version in this range also lies in `other`.
    ///
    /// The empty range is a subset of every range.
    @inlinable
    public func isSubset(of other: Self) -> Swift.Bool {
        if self.isEmpty { return true }
        return Self.lowerCoversOrEqual(other.lowerBound, vs: self.lowerBound)
            && Self.upperCoversOrEqual(other.upperBound, vs: self.upperBound)
    }

    /// Whether every version in `other` also lies in this range.
    @inlinable
    public func isSuperset(of other: Self) -> Swift.Bool {
        other.isSubset(of: self)
    }

    /// Whether every version in `other` also lies in this range.
    ///
    /// Range-overload of ``contains(_:)``. The single-version
    /// overload remains available for `Underlying` arguments;
    /// Swift resolves by parameter type.
    @inlinable
    public func contains(_ other: Self) -> Swift.Bool {
        other.isSubset(of: self)
    }

    // True when `enclosing` admits every version that `enclosed`
    // admits on the lower side — i.e. enclosing.lowerBound is at
    // least as permissive as enclosed.lowerBound.
    @usableFromInline
    static func lowerCoversOrEqual(_ enclosing: Bound, vs enclosed: Bound) -> Swift.Bool {
        switch (enclosing, enclosed) {
        case (.unbounded, _): return true
        case (_, .unbounded): return false

        case (.inclusive(let e), .inclusive(let i)): return e <= i
        case (.exclusive(let e), .exclusive(let i)): return e <= i

        // enclosing is inclusive(e), enclosed is exclusive(i):
        // enclosed admits (i, ...]; enclosing admits [e, ...].
        // enclosing covers enclosed iff e <= i (then (i, ...] ⊂ [e, ...]).
        case (.inclusive(let e), .exclusive(let i)): return e <= i

        // enclosing is exclusive(e), enclosed is inclusive(i):
        // enclosed admits [i, ...]; enclosing admits (e, ...].
        // enclosing covers enclosed iff e < i (so i > e, meaning [i, ...] ⊂ (e, ...]).
        case (.exclusive(let e), .inclusive(let i)): return e < i
        }
    }

    // Symmetric — enclosing.upperBound is at least as permissive as
    // enclosed.upperBound.
    @usableFromInline
    static func upperCoversOrEqual(_ enclosing: Bound, vs enclosed: Bound) -> Swift.Bool {
        switch (enclosing, enclosed) {
        case (.unbounded, _): return true
        case (_, .unbounded): return false

        case (.inclusive(let e), .inclusive(let i)): return e >= i
        case (.exclusive(let e), .exclusive(let i)): return e >= i

        case (.inclusive(let e), .exclusive(let i)): return e >= i
        case (.exclusive(let e), .inclusive(let i)): return e > i
        }
    }

    // Pick the more-restrictive (greater) lower bound. When values
    // are equal and one is exclusive, the exclusive wins (excludes
    // the value).
    @usableFromInline
    static func maxLowerBound(_ lhs: Bound, _ rhs: Bound) -> Bound {
        switch (lhs, rhs) {
        case (.unbounded, _): return rhs
        case (_, .unbounded): return lhs

        case (.inclusive(let l), .inclusive(let r)):
            return .inclusive(Swift.max(l, r))

        case (.exclusive(let l), .exclusive(let r)):
            return .exclusive(Swift.max(l, r))

        case (.inclusive(let i), .exclusive(let e)),
            (.exclusive(let e), .inclusive(let i)):
            if e > i { return .exclusive(e) }
            if i > e { return .inclusive(i) }
            // Equal — exclusive is more restrictive.
            return .exclusive(e)
        }
    }

    // Pick the more-restrictive (lesser) upper bound. When values
    // are equal and one is exclusive, the exclusive wins.
    @usableFromInline
    static func minUpperBound(_ lhs: Bound, _ rhs: Bound) -> Bound {
        switch (lhs, rhs) {
        case (.unbounded, _): return rhs
        case (_, .unbounded): return lhs

        case (.inclusive(let l), .inclusive(let r)):
            return .inclusive(Swift.min(l, r))

        case (.exclusive(let l), .exclusive(let r)):
            return .exclusive(Swift.min(l, r))

        case (.inclusive(let i), .exclusive(let e)),
            (.exclusive(let e), .inclusive(let i)):
            if e < i { return .exclusive(e) }
            if i < e { return .inclusive(i) }
            // Equal — exclusive is more restrictive.
            return .exclusive(e)
        }
    }
}
