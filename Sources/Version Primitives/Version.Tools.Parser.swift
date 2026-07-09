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
public import ASCII_Primitives
public import Byte_Parser_Primitives
public import Byte_Primitives
internal import Byte_Primitives_Standard_Library_Integration
public import Collection_Primitives
internal import Ordinal_Primitives
public import Parser_Primitives
public import Text_Primitives

extension Version.Tools {
    /// Byte-stream parser for SE-0152 tools versions.
    ///
    /// Conforms to `Parser_Primitives.Parser.\`Protocol\`` so the
    /// type can be composed inside larger byte-stream grammars
    /// (typically a Package.swift `// swift-tools-version: 6.3`
    /// comment scanner).
    public struct Parser<Input: Collection.Slice.`Protocol`>: Swift.Sendable
    where Input: Swift.Sendable, Input.Element == Byte {
        /// Creates a tools-version byte-stream parser.
        @inlinable
        public init() {}
    }
}

extension Version.Tools.Parser: Parser_Primitives.Parser.`Protocol` {
    /// The parsed value: a validated ``Version/Tools``.
    public typealias Output = Version.Tools

    /// The error type thrown on parse failure: ``Version/Tools/Error``.
    public typealias Failure = Version.Tools.Error

    /// Consumes an SE-0152 tools-version token from `input`.
    public func parse(_ input: inout Input) throws(Version.Tools.Error) -> Version.Tools {
        let originalSlice = input[input.startIndex..<Self.findToolsVersionEnd(in: input)]
        let originalString = Swift.String(decoding: originalSlice, as: Swift.UTF8.self)
        var offset: Index<Byte> = .zero

        let major = try Self.parseNumber(&input, offset: &offset, in: originalString)
        try Self.consumeDot(in: &input, offset: &offset, original: originalString)
        let minor = try Self.parseNumber(&input, offset: &offset, in: originalString)

        var patch: Swift.UInt?
        if input.first == 0x2E {
            input = input[input.index(after: input.startIndex)...]
            offset += .one
            patch = try Self.parseNumber(&input, offset: &offset, in: originalString)
        }

        return Version.Tools(
            major: .init(major),
            minor: .init(minor),
            patch: patch.map { Version.Tools.Patch.Value($0) }
        )
    }

    @usableFromInline
    static func findToolsVersionEnd(in input: Input) -> Input.Index {
        var i = input.startIndex
        while i < input.endIndex, Self.isToolsVersionByte(input[i]) {
            i = input.index(after: i)
        }
        return i
    }

    @inlinable
    package static func isToolsVersionByte(_ byte: Byte) -> Swift.Bool {
        ASCII.Classification.isDigit(byte.underlying) || byte == 0x2E
    }

    @inlinable
    package static func range(from start: Index<Byte>, to end: Index<Byte>) -> Text.Range {
        Text.Range(start: start.retag(Text.self), end: end.retag(Text.self))
    }

    @usableFromInline
    static func parseNumber(
        _ input: inout Input,
        offset: inout Index<Byte>,
        in originalString: Swift.String
    ) throws(Version.Tools.Error) -> Swift.UInt {
        let startOffset = offset
        guard let firstByte = input.first, ASCII.Classification.isDigit(firstByte.underlying) else {
            throw .invalidToolsVersionIdentifier(
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
                throw .invalidToolsVersionIdentifier(
                    input: originalString,
                    identifier: badRun,
                    range: Self.range(from: startOffset, to: startOffset + badSlice.count)
                )
            }
        }
        let countBefore = input.count
        let value: Swift.UInt
        do throws(ASCII.Decimal.Error) {
            value = try ASCII.Decimal.Parser<Input, Swift.UInt>().parse(&input)
        } catch {
            throw .invalidToolsVersionIdentifier(
                input: originalString,
                identifier: "",
                range: Self.range(from: startOffset, to: startOffset)
            )
        }
        offset += countBefore.subtract.saturating(input.count)
        return value
    }

    @usableFromInline
    static func consumeDot(
        in input: inout Input,
        offset: inout Index<Byte>,
        original originalString: Swift.String
    ) throws(Version.Tools.Error) {
        guard input.first == 0x2E else {
            throw .invalidToolsVersionIdentifierCount(
                input: originalString,
                range: Self.range(from: offset, to: offset)
            )
        }
        input = input[input.index(after: input.startIndex)...]
        offset += .one
    }
}
