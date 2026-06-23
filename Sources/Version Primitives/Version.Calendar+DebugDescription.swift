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

internal import Time_Primitives

extension Version.Calendar: Swift.CustomDebugStringConvertible {
    /// A structural representation preserving the case form and
    /// labeled associated values.
    ///
    /// Unlike ``description`` (which renders the canonical
    /// calver.org spelling — losing scheme identity in the rare case
    /// where two cases produce the same string), `debugDescription`
    /// preserves the case structure so `.yearMonth(year: 2026, month: 5)`
    /// is distinguishable from `.full(year: 2026, month: 5, micro: 0)`.
    public var debugDescription: Swift.String {
        switch self {
        case .yearOnly(let year, let modifier):
            return ".yearOnly(year: " + Self.format(year.rawValue)
                + ", modifier: " + Self.format(modifier) + ")"

        case .yearMonth(let year, let month, let modifier):
            return ".yearMonth(year: " + Self.format(year.rawValue)
                + ", month: " + Self.format(month.rawValue)
                + ", modifier: " + Self.format(modifier) + ")"

        case .full(let year, let month, let micro, let modifier):
            return ".full(year: " + Self.format(year.rawValue)
                + ", month: " + Self.format(month.rawValue)
                + ", micro: " + Self.format(Swift.Int(micro.underlying))
                + ", modifier: " + Self.format(modifier) + ")"
        }
    }

    @usableFromInline
    static func format(_ value: Swift.Int) -> Swift.String {
        Swift.String(value)
    }

    @usableFromInline
    static func format(_ modifier: Swift.String?) -> Swift.String {
        switch modifier {
        case .none: return "nil"
        case .some(let value): return "\"" + value + "\""
        }
    }
}
