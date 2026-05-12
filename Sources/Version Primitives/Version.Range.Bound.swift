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
    /// A lower or upper bound of a ``Version/Range``.
    ///
    /// - ``unbounded``: no bound on this side
    /// - ``inclusive(_:)``: the boundary value is part of the range
    /// - ``exclusive(_:)``: the boundary value is NOT part of the
    ///   range
    public enum Bound: Swift.Sendable, Swift.Hashable {
        /// No bound on this side — the range extends to infinity.
        case unbounded

        /// Boundary value is included in the range.
        case inclusive(Underlying)

        /// Boundary value is excluded from the range (open boundary).
        case exclusive(Underlying)
    }
}
