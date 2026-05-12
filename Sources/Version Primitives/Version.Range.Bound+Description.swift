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

extension Version.Range.Bound: Swift.CustomStringConvertible where Underlying: Swift.CustomStringConvertible {
    /// A textual representation of this boundary.
    ///
    /// The case form is preserved — `unbounded`, `inclusive(v)`,
    /// `exclusive(v)` — because a `Bound` printed in isolation has
    /// no side context to encode in mathematical brackets. The
    /// containing ``Version/Range`` renders bounds with brackets
    /// in its own description.
    public var description: Swift.String {
        switch self {
        case .unbounded:
            return "unbounded"

        case .inclusive(let value):
            return "inclusive(" + value.description + ")"

        case .exclusive(let value):
            return "exclusive(" + value.description + ")"
        }
    }
}
