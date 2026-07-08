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

public import Byte_Parser_Primitives
internal import Byte_Primitives_Standard_Library_Integration
internal import Ordinal_Primitives
public import Parser_Primitives
public import Tagged_Primitives
public import Text_Primitives
public import Time_Primitives

extension Version {
    /// Calendar Versioning per calver.org.
    ///
    /// CalVer has multiple canonical schemes — `YYYY`,
    /// `YYYY.MM`, and `YYYY.MM.MICRO` — optionally followed by a
    /// modifier (e.g., `2026.05.13-rc1`). The three cases capture
    /// these schemes exactly so round-trips preserve the original
    /// spelling.
    ///
    /// ## Comparison
    ///
    /// Comparison normalizes absent components to 0:
    /// `2026.05` (yearMonth) compares equal-order with `2026.5.0`
    /// (full), but they are NOT equal (the case carries scheme
    /// identity). Modifier-bearing versions order LOWER than the
    /// modifier-free version of the same components (mirrors
    /// SemVer §11.3 pre-release semantics).
    ///
    /// ```swift
    /// let cal = try Version.Calendar(parsing: "2026.05.13-rc1")
    /// // Pattern-match on the scheme:
    /// switch cal {
    /// case .full(let y, let m, let micro, let mod):
    ///     // y.rawValue == 2026, m.rawValue == 5, micro.underlying == 13
    /// case .yearMonth, .yearOnly:
    ///     break
    /// }
    /// ```
    ///
    /// The YEAR and MONTH components are typed as ``Time/Year`` and
    /// ``Time/Month`` from `swift-time-primitives` — `Time.Month`
    /// is a 1–12 refinement type so impossible months are rejected
    /// at construction. MICRO has no canonical institute equivalent
    /// (its meaning is scheme-dependent) and is typed as a
    /// `Tagged<Micro, Swift.UInt>` for type discrimination.
    public enum Calendar: Swift.Sendable, Swift.Hashable, Swift.Comparable, Swift.CustomStringConvertible, Swift.LosslessStringConvertible {
        /// Year-only CalVer (e.g., Ubuntu's `2024`).
        case yearOnly(year: Time.Year, modifier: Swift.String? = nil)

        /// Year + Month CalVer (e.g., Ubuntu's `24.04`).
        case yearMonth(year: Time.Year, month: Time.Month, modifier: Swift.String? = nil)

        /// Year + Month + Micro CalVer (e.g., `2026.05.13`).
        case full(year: Time.Year, month: Time.Month, micro: Micro.Value, modifier: Swift.String? = nil)

        /// Parses a CalVer per calver.org.
        ///
        /// - Throws: ``Version/Calendar/Error`` cases describing
        ///   which spec rule the input violated.
        public init(parsing calverString: Swift.String) throws(Version.Calendar.Error) {
            let totalBytes = Swift.UInt(calverString.utf8.count)
            for (offset, byte) in calverString.utf8.enumerated() where byte >= 0x80 {
                let position = Self.position(Swift.UInt(offset))
                throw .nonASCIICharacters(
                    input: calverString,
                    range: Text.Range(start: position, end: Self.position(Swift.UInt(offset) + 1))
                )
            }
            var input = Byte.Input(utf8: calverString)
            self = try Version.Calendar.Parser().parse(&input)
            if !input.isEmpty {
                let remaining = Swift.UInt(input.count)
                let consumed = totalBytes - remaining
                let trailing = Swift.String(decoding: input, as: Swift.UTF8.self)
                throw .invalidCalendarIdentifier(
                    input: calverString,
                    identifier: trailing,
                    range: Text.Range(
                        start: Self.position(consumed),
                        end: Self.position(totalBytes)
                    )
                )
            }
        }

        /// `LosslessStringConvertible` conformance — failable shim
        /// around ``Version/Calendar/init(parsing:)``.
        @inlinable
        public init?(_ description: Swift.String) {
            do {
                self = try .init(parsing: description)
            } catch {
                return nil
            }
        }
    }
}

extension Version.Calendar {
    /// Canonical calver.org spelling.
    ///
    /// Components present in the case are rendered; the
    /// modifier is appended with a leading `-` when present.
    public var description: Swift.String {
        var buffer: [Byte] = []
        Version.Calendar.Serializer<[Byte]>().serialize(self, into: &buffer)
        return Swift.String(decoding: buffer, as: Swift.UTF8.self)
    }

    /// calver.org-style precedence — normalizes absent
    /// components to 0; modifier-bearing versions order LOWER
    /// than modifier-free versions of the same numeric prefix.
    public static func < (lhs: Self, rhs: Self) -> Swift.Bool {
        let (ly, lm, lu, lmod) = lhs.normalized()
        let (ry, rm, ru, rmod) = rhs.normalized()
        if ly != ry { return ly < ry }
        if lm != rm { return lm < rm }
        if lu != ru { return lu < ru }
        switch (lmod, rmod) {
        case (nil, nil): return false
        case (nil, _?): return false
        case (_?, nil): return true
        case (let l?, let r?): return l < r
        }
    }

    // Normalize to (year, month, micro, modifier) with absent
    // numeric components mapped to 0 — for comparison only.
    @usableFromInline
    func normalized() -> (year: Swift.Int, month: Swift.Int, micro: Swift.Int, modifier: Swift.String?) {
        switch self {
        case .yearOnly(let y, let mod):
            return (y.rawValue, 0, 0, mod)

        case .yearMonth(let y, let m, let mod):
            return (y.rawValue, m.rawValue, 0, mod)

        case .full(let y, let m, let micro, let mod):
            return (y.rawValue, m.rawValue, Swift.Int(micro.underlying), mod)
        }
    }

    @inlinable
    package static func position(_ offset: Swift.UInt) -> Text.Position {
        Text.Position(_unchecked: Ordinal(offset))
    }
}
