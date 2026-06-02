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
public import ASCII_Primitives
public import Byte_Primitives
internal import Byte_Primitives_Standard_Library_Integration
public import Collection_Primitives
internal import Ordinal_Primitives
public import Parser_Primitives
public import Text_Primitives
internal import Time_Primitives_Core

extension Version.Calendar {
    /// Byte-stream parser for CalVer.
    ///
    /// Greedy over the CalVer character class
    /// (`[0-9A-Za-z.-]`). Distinguishes the three CalVer schemes
    /// (yearOnly, yearMonth, full) by the number of dot-separated
    /// numeric components consumed before any modifier.
    public struct Parser<Input: Collection.Slice.`Protocol`>: Swift.Sendable
    where Input: Swift.Sendable, Input.Element == Byte {
        /// Creates a CalVer byte-stream parser.
        ///
        /// Stateless — instances are interchangeable.
        @inlinable
        public init() {}
    }
}

extension Version.Calendar.Parser: Parser_Primitives.Parser.`Protocol` {
    /// The parsed value: a validated ``Version/Calendar``.
    public typealias Output = Version.Calendar

    /// The error type thrown on parse failure: ``Version/Calendar/Error``.
    public typealias Failure = Version.Calendar.Error

    /// Consumes a CalVer token from `input` and returns the parsed
    /// ``Version/Calendar`` value.
    ///
    /// Distinguishes ``Version/Calendar/yearOnly(year:modifier:)``,
    /// ``Version/Calendar/yearMonth(year:month:modifier:)``, and
    /// ``Version/Calendar/full(year:month:micro:modifier:)`` by the
    /// number of dot-separated numeric components consumed before
    /// the optional modifier suffix.
    public func parse(_ input: inout Input) throws(Version.Calendar.Error) -> Version.Calendar {
        let originalSlice = input[input.startIndex..<Self.findCalendarEnd(in: input)]
        let originalString = Swift.String(decoding: originalSlice, as: Swift.UTF8.self)
        var offset: Index<Byte> = .zero

        let yearValue = try Self.parseNumber(&input, offset: &offset, in: originalString)
        let year = Time.Year(Swift.Int(yearValue))

        var monthPair: (Time.Month, Swift.UInt)?
        var micro: Swift.UInt?

        if input.first == 0x2E {
            input = input[input.index(after: input.startIndex)...]
            offset += .one
            let monthStart = offset
            let monthValue = try Self.parseNumber(&input, offset: &offset, in: originalString)
            let timeMonth: Time.Month
            do {
                timeMonth = try Time.Month(Swift.Int(monthValue))
            } catch {
                throw .invalidMonth(
                    input: originalString,
                    value: Swift.Int(monthValue),
                    range: Self.range(from: monthStart, to: offset)
                )
            }
            monthPair = (timeMonth, monthValue)
            if input.first == 0x2E {
                input = input[input.index(after: input.startIndex)...]
                offset += .one
                micro = try Self.parseNumber(&input, offset: &offset, in: originalString)
            }
        }

        var modifier: Swift.String?
        if input.first == 0x2D {
            input = input[input.index(after: input.startIndex)...]
            offset += .one
            modifier = try Self.parseModifier(&input, offset: &offset, original: originalString)
        }

        switch (monthPair, micro) {
        case (nil, _):
            return .yearOnly(year: year, modifier: modifier)

        case (let pair?, nil):
            return .yearMonth(year: year, month: pair.0, modifier: modifier)

        case (let pair?, let u?):
            return .full(year: year, month: pair.0, micro: .init(u), modifier: modifier)
        }
    }

    @usableFromInline
    static func findCalendarEnd(in input: Input) -> Input.Index {
        var i = input.startIndex
        while i < input.endIndex, Self.isCalendarByte(input[i]) {
            i = input.index(after: i)
        }
        return i
    }

    @inlinable
    static func isCalendarByte(_ byte: Byte) -> Swift.Bool {
        ASCII.Classification.isAlphanumeric(byte.underlying) || byte == 0x2E || byte == 0x2D
    }

    @inlinable
    static func range(from start: Index<Byte>, to end: Index<Byte>) -> Text.Range {
        Text.Range(start: start.retag(Text.self), end: end.retag(Text.self))
    }

    @usableFromInline
    static func parseNumber(
        _ input: inout Input,
        offset: inout Index<Byte>,
        in originalString: Swift.String
    ) throws(Version.Calendar.Error) -> Swift.UInt {
        let startOffset = offset
        guard let firstByte = input.first, ASCII.Classification.isDigit(firstByte.underlying) else {
            throw .invalidCalendarIdentifier(
                input: originalString,
                identifier: "",
                range: Self.range(from: startOffset, to: startOffset)
            )
        }
        _ = firstByte
        let countBefore = input.count
        let value: Swift.UInt
        do {
            value = try ASCII.Decimal.Parser<Input, Swift.UInt>().parse(&input)
        } catch {
            throw .invalidCalendarIdentifier(
                input: originalString,
                identifier: "",
                range: Self.range(from: startOffset, to: startOffset)
            )
        }
        offset += countBefore.subtract.saturating(input.count)
        return value
    }

    @usableFromInline
    static func parseModifier(
        _ input: inout Input,
        offset: inout Index<Byte>,
        original originalString: Swift.String
    ) throws(Version.Calendar.Error) -> Swift.String {
        let startOffset = offset
        let startIndex = input.startIndex
        var i = startIndex
        while i < input.endIndex, Self.isModifierByte(input[i]) {
            i = input.index(after: i)
        }
        let slice = input[startIndex..<i]
        input = input[i...]
        offset += slice.count
        if slice.isEmpty {
            throw .emptyModifier(
                input: originalString,
                range: Self.range(from: startOffset, to: startOffset)
            )
        }
        let text = Swift.String(decoding: slice, as: Swift.UTF8.self)
        if !slice.allSatisfy({ Self.isModifierByte($0) }) {
            throw .invalidModifierCharacters(
                input: originalString,
                modifier: text,
                range: Self.range(from: startOffset, to: offset)
            )
        }
        return text
    }

    @inlinable
    static func isModifierByte(_ byte: Byte) -> Swift.Bool {
        ASCII.Classification.isAlphanumeric(byte.underlying) || byte == 0x2D
    }
}
