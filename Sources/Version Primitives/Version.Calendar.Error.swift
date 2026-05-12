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

public import Text_Primitives

extension Version.Calendar {
    /// Errors thrown by ``Version/Calendar/init(parsing:)`` and
    /// ``Version/Calendar/Parser/parse(_:)`` when input fails to
    /// satisfy calver.org syntax.
    ///
    /// Every case carries a `range: Text.Range` locating the
    /// offending byte span within the parsed input.
    public enum Error: Swift.Error, Swift.Sendable, Swift.Hashable {
        /// The input contains non-ASCII characters.
        case nonASCIICharacters(input: Swift.String, range: Text.Range)

        /// A numeric identifier is empty or non-numeric.
        case invalidCalendarIdentifier(input: Swift.String, identifier: Swift.String, range: Text.Range)

        /// The MONTH numeric value is outside the 1–12 range
        /// enforced by `Time.Month`.
        case invalidMonth(input: Swift.String, value: Swift.Int, range: Text.Range)

        /// The modifier suffix is empty (a `-` was present but
        /// followed by no characters).
        case emptyModifier(input: Swift.String, range: Text.Range)

        /// The modifier suffix contains characters outside
        /// `[0-9A-Za-z-]`.
        case invalidModifierCharacters(input: Swift.String, modifier: Swift.String, range: Text.Range)
    }
}

extension Version.Calendar.Error {
    /// The byte range within the parsed input where this error was
    /// located.
    @inlinable
    public var range: Text.Range {
        switch self {
        case .nonASCIICharacters(_, let range): return range
        case .invalidCalendarIdentifier(_, _, let range): return range
        case .invalidMonth(_, _, let range): return range
        case .emptyModifier(_, let range): return range
        case .invalidModifierCharacters(_, _, let range): return range
        }
    }

    /// The input string that the parser was given.
    @inlinable
    public var input: Swift.String {
        switch self {
        case .nonASCIICharacters(let input, _): return input
        case .invalidCalendarIdentifier(let input, _, _): return input
        case .invalidMonth(let input, _, _): return input
        case .emptyModifier(let input, _): return input
        case .invalidModifierCharacters(let input, _, _): return input
        }
    }
}
