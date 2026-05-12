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

public import ASCII_Primitives
public import Serializer_Primitives
public import Time_Primitives_Core

extension Version.Calendar {
    /// Byte-stream serializer for CalVer.
    ///
    /// Renders each scheme exactly — `yearOnly` produces `YYYY`,
    /// `yearMonth` produces `YYYY.MM`, `full` produces
    /// `YYYY.MM.MICRO`. The modifier, if present, is appended with
    /// a leading `-`.
    public struct Serializer<Buffer: Swift.RangeReplaceableCollection>: Swift.Sendable
    where Buffer: Swift.Sendable, Buffer.Element == Swift.UInt8 {
        /// Creates a CalVer byte-stream serializer.
        ///
        /// Stateless — instances are interchangeable.
        @inlinable
        public init() {}
    }
}

extension Version.Calendar.Serializer: Serializer_Primitives.Serializer.`Protocol` {
    /// The serialized value: a validated ``Version/Calendar``.
    public typealias Output = Version.Calendar

    /// Infallible.
    public typealias Failure = Swift.Never

    /// Appends the canonical CalVer byte form of `output` to
    /// `buffer`.
    ///
    /// Month and micro components below 10 are zero-padded to two
    /// digits (canonical `0M` / `0D` form per calver.org). Year is
    /// rendered unpadded.
    @inlinable
    public func serialize(_ output: Version.Calendar, into buffer: inout Buffer) {
        switch output {
        case .yearOnly(let year, let modifier):
            ASCII.Serialization.serializeDecimal(Swift.UInt(year.rawValue), into: &buffer)
            Self.appendModifier(modifier, into: &buffer)

        case .yearMonth(let year, let month, let modifier):
            ASCII.Serialization.serializeDecimal(Swift.UInt(year.rawValue), into: &buffer)
            buffer.append(0x2E)
            Self.appendPadded(Swift.UInt(month.rawValue), into: &buffer)
            Self.appendModifier(modifier, into: &buffer)

        case .full(let year, let month, let micro, let modifier):
            ASCII.Serialization.serializeDecimal(Swift.UInt(year.rawValue), into: &buffer)
            buffer.append(0x2E)
            Self.appendPadded(Swift.UInt(month.rawValue), into: &buffer)
            buffer.append(0x2E)
            Self.appendPadded(micro.underlying, into: &buffer)
            Self.appendModifier(modifier, into: &buffer)
        }
    }

    // Renders the value with at least 2 digits — left-pads with '0'
    // if value < 10. Matches the canonical CalVer `0M` / `0D` form
    // (Ubuntu `24.04`, dates `2026.05.13`).
    @inlinable
    static func appendPadded(_ value: Swift.UInt, into buffer: inout Buffer) {
        if value < 10 {
            buffer.append(0x30)
        }
        ASCII.Serialization.serializeDecimal(value, into: &buffer)
    }

    @inlinable
    static func appendModifier(_ modifier: Swift.String?, into buffer: inout Buffer) {
        if let modifier {
            buffer.append(0x2D)
            buffer.append(contentsOf: modifier.utf8)
        }
    }
}
