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

extension Version.Set: Swift.CustomStringConvertible where Underlying: Swift.CustomStringConvertible {
    /// A textual representation of this version-set using
    /// set-theoretic notation.
    ///
    /// | Case | Rendered as |
    /// |---|---|
    /// | ``empty`` | `∅` |
    /// | ``any`` | `*` |
    /// | ``exact(_:)`` `v` | `{v}` |
    /// | ``range(_:)`` `r` | `r.description` (e.g., `[1.0.0, 2.0.0)`) |
    /// | ``union(_:)`` `[a, b, c]` | `(a ∪ b ∪ c)` |
    /// | ``union(_:)`` `[]` | `∅` |
    /// | ``union(_:)`` `[a]` | `a.description` |
    public var description: Swift.String {
        switch self {
        case .empty:
            return "∅"

        case .any:
            return "*"

        case .exact(let value):
            return "{" + value.description + "}"

        case .range(let interval):
            return interval.description

        case .union(let members):
            switch members.count {
            case 0:
                return "∅"

            case 1:
                return members[0].description

            default:
                return "(" + members.map(\.description).joined(separator: " ∪ ") + ")"
            }
        }
    }
}

extension Version.Set: Swift.CustomDebugStringConvertible where Underlying: Swift.CustomStringConvertible {
    /// A structural representation preserving the case form and
    /// nested structure.
    ///
    /// Unlike ``description`` (which normalizes `.union([])` to `∅`
    /// and prints `.range(r)` as the inner `r`), `debugDescription`
    /// renders each case with its label and reflects the literal
    /// case structure — useful when debugging normalization rules
    /// or distinguishing two semantically-equal representations.
    public var debugDescription: Swift.String {
        switch self {
        case .empty:
            return ".empty"

        case .any:
            return ".any"

        case .exact(let value):
            return ".exact(" + value.description + ")"

        case .range(let interval):
            return ".range(" + interval.description + ")"

        case .union(let members):
            let inner = members.map(\.debugDescription).joined(separator: ", ")
            return ".union([" + inner + "])"
        }
    }
}
