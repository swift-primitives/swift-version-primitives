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

public import ASCII_Decimal_Parser_Primitives
public import Byte_Parser_Primitives
internal import Byte_Primitives_Standard_Library_Integration
public import ASCII_Primitives
public import Collection_Primitives
internal import Ordinal_Primitives
public import Parser_Primitives
public import Text_Primitives

extension Version.Semantic {
    /// Byte-stream parser for SemVer 2.0.0 — participates in larger
    /// `Parser_Primitives.Parser.\`Protocol\``-bound grammars.
    ///
    /// Composes with the institute parser ecosystem (HTTP header
    /// parsers, package-manifest parsers, registry-locator parsers)
    /// that operate on `UInt8` byte streams. Inside its `parse(_:)`
    /// body the Parser delegates to ``ASCII/Decimal/Parser`` for each
    /// numeric component and to ``ASCII/Classification`` predicates
    /// for identifier character-class checks — there is no
    /// hand-rolled byte arithmetic.
    ///
    /// Errors thrown by the Parser carry `Text.Range` spans locating
    /// the offending byte run, suitable for IDE / tooling
    /// highlighting.
    ///
    /// The Parser is the canonical source of SemVer validation
    /// logic. ``Version/Semantic/init(parsing:)`` is a thin String
    /// adapter that runs this parser over the UTF-8 view of the
    /// supplied string and asserts the input is exhausted.
    ///
    /// ```swift
    /// var input = Byte.Input(utf8: "1.2.3-alpha+sha.abc")
    /// let version = try Version.Semantic.Parser().parse(&input)
    /// // version.major.underlying == 1
    /// ```
    public struct Parser<Input: Collection.Slice.`Protocol`>: Swift.Sendable
    where Input: Swift.Sendable, Input.Element == Byte {
        /// Creates a SemVer 2.0.0 byte-stream parser.
        ///
        /// Stateless — instances are interchangeable.
        @inlinable
        public init() {}
    }
}

extension Version.Semantic.Parser: Parser_Primitives.Parser.`Protocol` {
    /// The parsed value: a validated ``Version/Semantic``.
    public typealias Output = Version.Semantic

    /// The error type thrown on parse failure: ``Version/Semantic/Error``.
    public typealias Failure = Version.Semantic.Error

    /// Consumes a SemVer 2.0.0 token from `input` and returns the
    /// parsed ``Version/Semantic``.
    ///
    /// The parser is greedy over the SemVer character class
    /// (`[0-9A-Za-z.+-]`) and stops at the first byte outside that
    /// class. Validation against §2/§9/§10 is performed inline;
    /// failures throw ``Version/Semantic/Error`` with the
    /// surrounding context and a `Text.Range` locating the offending
    /// byte span.
    public func parse(_ input: inout Input) throws(Version.Semantic.Error) -> Version.Semantic {
        let originalSlice = input[input.startIndex..<Self.findSemVerEnd(in: input)]
        let originalString = Swift.String(decoding: originalSlice, as: Swift.UTF8.self)
        var offset: Index<Byte> = .zero

        let major = try Self.parseCoreNumber(&input, offset: &offset, in: originalString)
        try Self.consumeDelimiter(0x2E, in: &input, offset: &offset, original: originalString)
        let minor = try Self.parseCoreNumber(&input, offset: &offset, in: originalString)
        try Self.consumeDelimiter(0x2E, in: &input, offset: &offset, original: originalString)
        let patch = try Self.parseCoreNumber(&input, offset: &offset, in: originalString)

        var preRelease: [Version.Semantic.Identifier] = []
        if input.first == 0x2D {
            input = input[input.index(after: input.startIndex)...]
            offset += .one
            preRelease = try Self.parsePreReleaseIdentifiers(&input, offset: &offset, original: originalString)
        }

        var build: [Swift.String] = []
        if input.first == 0x2B {
            input = input[input.index(after: input.startIndex)...]
            offset += .one
            build = try Self.parseBuildMetadataIdentifiers(&input, offset: &offset, original: originalString)
        }

        return Version.Semantic(
            major: .init(major),
            minor: .init(minor),
            patch: .init(patch),
            preReleaseIdentifiers: preRelease,
            buildMetadataIdentifiers: build
        )
    }

    // Locates the end of the greedy SemVer character run for error-
    // context reconstruction. Does not advance `input` — `parse(_:)`
    // does that via the per-component sub-parsers.
    @usableFromInline
    static func findSemVerEnd(in input: Input) -> Input.Index {
        var i = input.startIndex
        while i < input.endIndex, Self.isSemVerByte(input[i]) {
            i = input.index(after: i)
        }
        return i
    }

    @inlinable
    static func isSemVerByte(_ byte: Byte) -> Swift.Bool {
        ASCII.Classification.isAlphanumeric(byte.underlying) || byte == 0x2E || byte == 0x2D || byte == 0x2B
    }

    @inlinable
    static func range(from start: Index<Byte>, to end: Index<Byte>) -> Text.Range {
        Text.Range(start: start.retag(Text.self), end: end.retag(Text.self))
    }

    // §2 — MAJOR / MINOR / PATCH: numeric, no leading zeros.
    @usableFromInline
    static func parseCoreNumber(
        _ input: inout Input,
        offset: inout Index<Byte>,
        in originalString: Swift.String
    ) throws(Version.Semantic.Error) -> Swift.UInt {
        let startOffset = offset
        guard let firstByte = input.first, ASCII.Classification.isDigit(firstByte.underlying) else {
            throw .invalidVersionCoreIdentifier(
                input: originalString,
                identifier: "",
                range: Self.range(from: startOffset, to: startOffset)
            )
        }
        if firstByte == 0x30 {
            let nextIdx = input.index(after: input.startIndex)
            if nextIdx < input.endIndex, ASCII.Classification.isDigit(input[nextIdx].underlying) {
                var i = input.startIndex
                while i < input.endIndex, ASCII.Classification.isDigit(input[i].underlying) {
                    i = input.index(after: i)
                }
                let badSlice = input[input.startIndex..<i]
                let badRun = Swift.String(decoding: badSlice, as: Swift.UTF8.self)
                throw .invalidVersionCoreIdentifier(
                    input: originalString,
                    identifier: badRun,
                    range: Self.range(from: startOffset, to: startOffset + badSlice.count)
                )
            }
        }
        let countBefore = input.count
        let value: Swift.UInt
        do {
            value = try ASCII.Decimal.Parser<Input, Swift.UInt>().parse(&input)
        } catch {
            throw .invalidVersionCoreIdentifier(
                input: originalString,
                identifier: "",
                range: Self.range(from: startOffset, to: startOffset)
            )
        }
        offset += countBefore.subtract.saturating(input.count)
        return value
    }

    // Expects exactly the given delimiter byte at the head of input
    // and advances past it. Reports the dot-count error when the
    // core's three-identifier structure is violated.
    @usableFromInline
    static func consumeDelimiter(
        _ byte: Byte,
        in input: inout Input,
        offset: inout Index<Byte>,
        original originalString: Swift.String
    ) throws(Version.Semantic.Error) {
        guard input.first == byte else {
            throw .invalidVersionCoreIdentifierCount(
                input: originalString,
                found: Self.countCoreParts(in: originalString),
                range: Self.range(from: offset, to: offset)
            )
        }
        input = input[input.index(after: input.startIndex)...]
        offset += .one
    }

    // Counts dot-separated segments in the version-core portion
    // (the prefix before any '-' or '+'). Populates the §2 dot-count
    // error's `found` parameter.
    @usableFromInline
    static func countCoreParts(in original: Swift.String) -> Swift.Int {
        var count = 1
        for byte in original.utf8 {
            if byte == 0x2D || byte == 0x2B { break }
            if byte == 0x2E { count += 1 }
        }
        return count
    }

    // §9 — pre-release: identifier ("." identifier)*. Each
    // identifier is non-empty, character class `[0-9A-Za-z-]`. A
    // purely-numeric identifier additionally rejects leading zeros.
    @usableFromInline
    static func parsePreReleaseIdentifiers(
        _ input: inout Input,
        offset: inout Index<Byte>,
        original originalString: Swift.String
    ) throws(Version.Semantic.Error) -> [Version.Semantic.Identifier] {
        var identifiers: [Version.Semantic.Identifier] = []
        repeat {
            let startOffset = offset
            let identifierSlice = Self.takeIdentifier(&input, offset: &offset)
            if identifierSlice.isEmpty {
                throw .emptyPreReleaseIdentifier(
                    input: originalString,
                    range: Self.range(from: startOffset, to: startOffset)
                )
            }
            let text = Swift.String(decoding: identifierSlice, as: Swift.UTF8.self)
            let range = Self.range(from: startOffset, to: offset)
            if !identifierSlice.allSatisfy({ Self.isIdentifierByte($0) }) {
                throw .invalidPreReleaseIdentifierCharacters(
                    input: originalString,
                    identifier: text,
                    range: range
                )
            }
            let allDigits = identifierSlice.allSatisfy { ASCII.Classification.isDigit($0.underlying) }
            if allDigits {
                if identifierSlice.first == 0x30 && identifierSlice.index(after: identifierSlice.startIndex) < identifierSlice.endIndex {
                    throw .leadingZeroInNumericPreReleaseIdentifier(
                        input: originalString,
                        identifier: text,
                        range: range
                    )
                }
                guard let value = Swift.UInt(text) else {
                    throw .invalidPreReleaseIdentifierCharacters(
                        input: originalString,
                        identifier: text,
                        range: range
                    )
                }
                identifiers.append(.numeric(value))
            } else {
                identifiers.append(.alphanumeric(text))
            }
        } while Self.consumeIfDot(&input, offset: &offset)
        return identifiers
    }

    // §10 — build metadata: identifier ("." identifier)*. Same
    // character class as §9 but no numeric/alphanumeric split and
    // no leading-zero rule.
    @usableFromInline
    static func parseBuildMetadataIdentifiers(
        _ input: inout Input,
        offset: inout Index<Byte>,
        original originalString: Swift.String
    ) throws(Version.Semantic.Error) -> [Swift.String] {
        var identifiers: [Swift.String] = []
        repeat {
            let startOffset = offset
            let identifierSlice = Self.takeIdentifier(&input, offset: &offset)
            if identifierSlice.isEmpty {
                throw .emptyBuildMetadataIdentifier(
                    input: originalString,
                    range: Self.range(from: startOffset, to: startOffset)
                )
            }
            let text = Swift.String(decoding: identifierSlice, as: Swift.UTF8.self)
            if !identifierSlice.allSatisfy({ Self.isIdentifierByte($0) }) {
                throw .invalidBuildMetadataIdentifierCharacters(
                    input: originalString,
                    identifier: text,
                    range: Self.range(from: startOffset, to: offset)
                )
            }
            identifiers.append(text)
        } while Self.consumeIfDot(&input, offset: &offset)
        return identifiers
    }

    // Consumes a maximal run of bytes up to (but not including) the
    // next '.' or '+'. The caller validates the character class on
    // the returned slice — this scanner is permissive so callers
    // can surface the specific spec-section's error case.
    @usableFromInline
    static func takeIdentifier(_ input: inout Input, offset: inout Index<Byte>) -> Input {
        let startIndex = input.startIndex
        var i = startIndex
        while i < input.endIndex {
            let byte = input[i]
            if byte == 0x2E || byte == 0x2B { break }
            i = input.index(after: i)
        }
        let slice = input[startIndex..<i]
        input = input[i...]
        offset += slice.count
        return slice
    }

    @inlinable
    static func isIdentifierByte(_ byte: Byte) -> Swift.Bool {
        ASCII.Classification.isAlphanumeric(byte.underlying) || byte == 0x2D
    }

    // Advances past a leading '.' if present. Chains dot-separated
    // identifiers inside pre-release and build-metadata segments.
    @usableFromInline
    static func consumeIfDot(_ input: inout Input, offset: inout Index<Byte>) -> Swift.Bool {
        if input.first == 0x2E {
            input = input[input.index(after: input.startIndex)...]
            offset += .one
            return true
        }
        return false
    }
}
