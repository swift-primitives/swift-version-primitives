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

extension Version.Range: Swift.CustomStringConvertible where Underlying: Swift.CustomStringConvertible {
    /// A textual representation of this range using mathematical
    /// interval notation.
    ///
    /// | Range shape | Rendered as |
    /// |---|---|
    /// | ``Version/Range/all`` | `(-∞, +∞)` |
    /// | ``Version/Range/exact(_:)`` `v` | `[v, v]` |
    /// | `[lo, hi)` | `[lo, hi)` (canonical half-open) |
    /// | `(lo, hi]` | `(lo, hi]` |
    /// | `[lo, +∞)` | `[lo, +∞)` |
    /// | `(-∞, hi]` | `(-∞, hi]` |
    public var description: Swift.String {
        let left: Swift.String
        switch self.lowerBound {
        case .unbounded:
            left = "(-∞"

        case .inclusive(let value):
            left = "[" + value.description

        case .exclusive(let value):
            left = "(" + value.description
        }
        let right: Swift.String
        switch self.upperBound {
        case .unbounded:
            right = "+∞)"

        case .inclusive(let value):
            right = value.description + "]"

        case .exclusive(let value):
            right = value.description + ")"
        }
        return left + ", " + right
    }
}
