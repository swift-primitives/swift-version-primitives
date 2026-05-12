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

extension Version.Tools {
    /// Errors thrown by ``Version/Tools/init(parsing:)`` and
    /// ``Version/Tools/Parser/parse(_:)`` when input fails to
    /// satisfy SE-0152 syntax.
    ///
    /// Every case carries a `range: Text.Range` locating the
    /// offending byte span within the parsed input.
    public enum Error: Swift.Error, Swift.Sendable, Swift.Hashable {
        /// The input contains non-ASCII characters. SE-0152 syntax
        /// is ASCII-only.
        case nonASCIICharacters(input: Swift.String, range: Text.Range)

        /// The input does not parse as either `MAJOR.MINOR` or
        /// `MAJOR.MINOR.PATCH` — too few or too many dot-separated
        /// identifiers.
        case invalidToolsVersionIdentifierCount(input: Swift.String, range: Text.Range)

        /// A numeric identifier is empty, non-numeric, or contains a
        /// leading zero.
        case invalidToolsVersionIdentifier(input: Swift.String, identifier: Swift.String, range: Text.Range)
    }
}

extension Version.Tools.Error {
    /// The byte range within the parsed input where this error was
    /// located.
    @inlinable
    public var range: Text.Range {
        switch self {
        case .nonASCIICharacters(_, let range): return range
        case .invalidToolsVersionIdentifierCount(_, let range): return range
        case .invalidToolsVersionIdentifier(_, _, let range): return range
        }
    }

    /// The input string that the parser was given.
    @inlinable
    public var input: Swift.String {
        switch self {
        case .nonASCIICharacters(let input, _): return input
        case .invalidToolsVersionIdentifierCount(let input, _): return input
        case .invalidToolsVersionIdentifier(let input, _, _): return input
        }
    }
}
