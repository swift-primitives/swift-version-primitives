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
    /// Construct a `Version.Range` from a `Swift.Range` — the
    /// half-open `lower..<upper` form. The resulting range has an
    /// inclusive lower bound and an exclusive upper bound, matching
    /// SwiftPM's canonical `"X.Y.Z"..<"A.B.C"` semantics for
    /// `.package(url:_:products:)` version ranges.
    ///
    /// Combined with `Version.Semantic`'s
    /// `ExpressibleByStringLiteral` conformance, call sites can
    /// write `Version.Range("1.0.0"..<"2.0.0")` — the literal
    /// half-open range produced by `..<` lifts directly into the
    /// typed shape.
    ///
    /// Strideable is NOT applied to `Version.Semantic`: the spec
    /// defines no natural stride on semantic versions (no
    /// `Version + 1` semantics), so `..<` produces a `Swift.Range`
    /// over a `Comparable` underlying rather than a `Stride`-based
    /// `CountableRange`. This init is the bridge from the
    /// `Comparable` range shape to the typed `Version.Range` form.
    @inlinable
    public init(_ range: Swift.Range<Underlying>) {
        self.init(
            lowerBound: .inclusive(range.lowerBound),
            upperBound: .exclusive(range.upperBound)
        )
    }
}
