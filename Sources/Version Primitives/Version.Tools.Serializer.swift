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

extension Version.Tools {
    /// Byte-stream serializer for SE-0152 tools versions.
    ///
    /// Pairs with ``Version/Tools/Parser`` for Parser+Serializer
    /// round-trip symmetry. PATCH is emitted only when present on
    /// the typed value, so `"6.3"` round-trips back to `"6.3"`
    /// rather than `"6.3.0"`.
    public struct Serializer<Buffer: Swift.RangeReplaceableCollection>: Swift.Sendable
    where Buffer: Swift.Sendable, Buffer.Element == Byte {
        /// Creates a tools-version byte-stream serializer.
        ///
        /// Stateless — instances are interchangeable.
        @inlinable
        public init() {}
    }
}

extension Version.Tools.Serializer: Serializer_Primitives.Serializer.`Protocol` {
    /// The serialized value: a validated ``Version/Tools``.
    public typealias Output = Version.Tools

    /// Infallible.
    public typealias Failure = Swift.Never

    /// Appends the canonical SE-0152 byte form to `buffer`.
    @inlinable
    public func serialize(_ output: Version.Tools, into buffer: inout Buffer) {
        ASCII.Decimal.serialize(output.major.underlying, into: &buffer)
        buffer.append(0x2E)
        ASCII.Decimal.serialize(output.minor.underlying, into: &buffer)
        if let patch = output.patch {
            buffer.append(0x2E)
            ASCII.Decimal.serialize(patch.underlying, into: &buffer)
        }
    }
}
