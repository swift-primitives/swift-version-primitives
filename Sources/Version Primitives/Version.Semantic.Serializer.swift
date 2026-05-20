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

extension Version.Semantic {
    /// Byte-stream serializer for SemVer 2.0.0 — the printer side of
    /// the Parser/Serializer round-trip.
    ///
    /// Appends the canonical SemVer 2.0.0 byte form of a
    /// ``Version/Semantic`` value to a buffer. Composes with the
    /// institute serializer ecosystem; pairs with
    /// ``Version/Semantic/Parser`` to give the type round-trip
    /// symmetry: `parse(serialize(v)) == v` for any valid `v`.
    ///
    /// ```swift
    /// var buffer: [Byte] = []
    /// Version.Semantic.Serializer().serialize(version, into: &buffer)
    /// // buffer holds the UTF-8 of "1.2.3-alpha.1+sha.abc"
    /// ```
    ///
    /// The serializer cannot fail — `Failure == Swift.Never`. The
    /// ``Version/Semantic`` value is already validated at
    /// construction, so every byte written satisfies the spec
    /// character class.
    public struct Serializer<Buffer: Swift.RangeReplaceableCollection>: Swift.Sendable
    where Buffer: Swift.Sendable, Buffer.Element == Byte {
        /// Creates a SemVer 2.0.0 byte-stream serializer.
        ///
        /// Stateless — instances are interchangeable.
        @inlinable
        public init() {}
    }
}

extension Version.Semantic.Serializer: Serializer_Primitives.Serializer.`Protocol` {
    /// The value serialized: a validated ``Version/Semantic``.
    public typealias Output = Version.Semantic

    /// Infallible — `Version.Semantic` is always serializable.
    public typealias Failure = Swift.Never

    /// Appends the canonical SemVer 2.0.0 byte form of `output` to
    /// `buffer`.
    ///
    /// The form is `MAJOR.MINOR.PATCH` followed optionally by
    /// `-<pre-release>` and/or `+<build-metadata>`. Each numeric
    /// component is rendered via ``ASCII/Serialization/serializeDecimal(_:into:)``;
    /// alphanumeric identifiers are appended directly as their
    /// UTF-8 bytes.
    @inlinable
    public func serialize(_ output: Version.Semantic, into buffer: inout Buffer) {
        ASCII.Serialization.serializeDecimal(output.major.underlying, into: &buffer)
        buffer.append(0x2E)
        ASCII.Serialization.serializeDecimal(output.minor.underlying, into: &buffer)
        buffer.append(0x2E)
        ASCII.Serialization.serializeDecimal(output.patch.underlying, into: &buffer)

        if !output.preReleaseIdentifiers.isEmpty {
            buffer.append(0x2D)
            for (index, identifier) in output.preReleaseIdentifiers.enumerated() {
                if index > 0 {
                    buffer.append(0x2E)
                }
                switch identifier {
                case .numeric(let value):
                    ASCII.Serialization.serializeDecimal(value, into: &buffer)

                case .alphanumeric(let text):
                    buffer.append(contentsOf: text.utf8.lazy.map(Byte.init))
                }
            }
        }

        if !output.buildMetadataIdentifiers.isEmpty {
            buffer.append(0x2B)
            for (index, identifier) in output.buildMetadataIdentifiers.enumerated() {
                if index > 0 {
                    buffer.append(0x2E)
                }
                buffer.append(contentsOf: identifier.utf8.lazy.map(Byte.init))
            }
        }
    }
}
