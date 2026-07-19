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

extension Version.Semantic {
    /// Errors thrown by ``Version/Semantic/init(parsing:)`` and
    /// ``Version/Semantic/Parser/parse(_:)`` when input fails to
    /// satisfy SemVer 2.0.0 (semver.org).
    ///
    /// Every case carries a `range: Text.Range` locating the
    /// offending byte span within the parsed input — usable by
    /// IDE/tooling consumers for diagnostic highlighting.
    public enum Error: Swift.Error, Swift.Sendable, Swift.Hashable {
        /// The version string contains non-ASCII characters.
        ///
        /// SemVer 2.0.0 §9–§10 restrict identifiers to ASCII alphanumerics
        /// and hyphens.
        case nonASCIICharacters(input: Swift.String, range: Text.Range)

        /// The version core (the dot-separated MAJOR.MINOR.PATCH
        /// prefix) does not contain exactly three identifiers per
        /// SemVer 2.0.0 §2.
        case invalidVersionCoreIdentifierCount(input: Swift.String, found: Swift.Int, range: Text.Range)

        /// A version-core identifier is empty, non-numeric, or
        /// contains a leading zero (SemVer 2.0.0 §2 forbids leading
        /// zeros in MAJOR, MINOR, PATCH).
        case invalidVersionCoreIdentifier(input: Swift.String, identifier: Swift.String, range: Text.Range)

        /// A pre-release identifier is empty per SemVer 2.0.0 §9.
        case emptyPreReleaseIdentifier(input: Swift.String, range: Text.Range)

        /// A pre-release identifier contains characters outside
        /// `[0-9A-Za-z-]` per SemVer 2.0.0 §9.
        case invalidPreReleaseIdentifierCharacters(input: Swift.String, identifier: Swift.String, range: Text.Range)

        /// A pre-release numeric identifier contains a leading zero
        /// per SemVer 2.0.0 §9.
        case leadingZeroInNumericPreReleaseIdentifier(input: Swift.String, identifier: Swift.String, range: Text.Range)

        /// A build-metadata identifier is empty per SemVer 2.0.0
        /// §10.
        case emptyBuildMetadataIdentifier(input: Swift.String, range: Text.Range)

        /// A build-metadata identifier contains characters outside
        /// `[0-9A-Za-z-]` per SemVer 2.0.0 §10.
        case invalidBuildMetadataIdentifierCharacters(input: Swift.String, identifier: Swift.String, range: Text.Range)
    }
}

extension Version.Semantic.Error {
    /// The byte range within the parsed input where this error was
    /// located.
    @inlinable
    public var range: Text.Range {
        switch self {
        case .nonASCIICharacters(_, let range): return range
        case .invalidVersionCoreIdentifierCount(_, _, let range): return range
        case .invalidVersionCoreIdentifier(_, _, let range): return range
        case .emptyPreReleaseIdentifier(_, let range): return range
        case .invalidPreReleaseIdentifierCharacters(_, _, let range): return range
        case .leadingZeroInNumericPreReleaseIdentifier(_, _, let range): return range
        case .emptyBuildMetadataIdentifier(_, let range): return range
        case .invalidBuildMetadataIdentifierCharacters(_, _, let range): return range
        }
    }

    /// The input string that the parser was given.
    @inlinable
    public var input: Swift.String {
        switch self {
        case .nonASCIICharacters(let input, _): return input
        case .invalidVersionCoreIdentifierCount(let input, _, _): return input
        case .invalidVersionCoreIdentifier(let input, _, _): return input
        case .emptyPreReleaseIdentifier(let input, _): return input
        case .invalidPreReleaseIdentifierCharacters(let input, _, _): return input
        case .leadingZeroInNumericPreReleaseIdentifier(let input, _, _): return input
        case .emptyBuildMetadataIdentifier(let input, _): return input
        case .invalidBuildMetadataIdentifierCharacters(let input, _, _): return input
        }
    }
}
