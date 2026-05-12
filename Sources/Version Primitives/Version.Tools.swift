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

public import Parser_Primitives
public import Tagged_Primitives
public import Text_Primitives

extension Version {
    /// Swift Package Manager tools version per SE-0152.
    ///
    /// Format: `MAJOR.MINOR[.PATCH]`. PATCH is optional and
    /// defaults to 0 when absent in source — but the absence is
    /// preserved on the typed value so round-tripping through
    /// description produces the original spelling.
    ///
    /// `Version.Tools` is a strict SemVer subset (no pre-release,
    /// no build-metadata). Comparison is purely numeric on
    /// `(major, minor, patch ?? 0)`.
    ///
    /// ```swift
    /// let v = try Version.Tools(parsing: "6.3")
    /// v.major.underlying  // 6
    /// v.minor.underlying  // 3
    /// v.patch             // nil — patch was absent in source
    /// v.description       // "6.3" — round-trips
    /// ```
    public struct Tools: Swift.Sendable, Swift.Hashable, Swift.Comparable, Swift.CustomStringConvertible, Swift.LosslessStringConvertible {
        /// The MAJOR version component per SE-0152.
        public let major: Major.Value

        /// The MINOR version component per SE-0152.
        public let minor: Minor.Value

        /// The PATCH version component per SE-0152.
        ///
        /// `nil` when absent in source. For comparison purposes
        /// `nil` is treated identically to `0`.
        public let patch: Patch.Value?

        /// Constructs a tools-version from its components.
        @inlinable
        public init(
            major: Major.Value,
            minor: Minor.Value,
            patch: Patch.Value? = nil
        ) {
            self.major = major
            self.minor = minor
            self.patch = patch
        }

        /// Parses a tools-version per SE-0152.
        ///
        /// - Throws: ``Version/Tools/Error`` cases describing
        ///   which spec rule the input violated.
        public init(parsing toolsString: Swift.String) throws(Version.Tools.Error) {
            let totalBytes = Swift.UInt(toolsString.utf8.count)
            for (offset, byte) in toolsString.utf8.enumerated() where byte >= 0x80 {
                let position = Self.position(Swift.UInt(offset))
                throw .nonASCIICharacters(
                    input: toolsString,
                    range: Text.Range(start: position, end: Self.position(Swift.UInt(offset) + 1))
                )
            }
            var input = Parser_Primitives.Parser.Input.Bytes(utf8: toolsString)
            self = try Version.Tools.Parser().parse(&input)
            if !input.isEmpty {
                let remaining = Swift.UInt(input.count)
                let consumed = totalBytes - remaining
                throw .invalidToolsVersionIdentifierCount(
                    input: toolsString,
                    range: Text.Range(
                        start: Self.position(consumed),
                        end: Self.position(totalBytes)
                    )
                )
            }
        }

        /// `LosslessStringConvertible` conformance — failable shim
        /// around ``Version/Tools/init(parsing:)``.
        @inlinable
        public init?(_ description: Swift.String) {
            do {
                self = try .init(parsing: description)
            } catch {
                return nil
            }
        }

        /// Canonical SE-0152 spelling.
        ///
        /// PATCH is rendered only when the source had it.
        public var description: Swift.String {
            var buffer: [Swift.UInt8] = []
            Version.Tools.Serializer<[Swift.UInt8]>().serialize(self, into: &buffer)
            return Swift.String(decoding: buffer, as: Swift.UTF8.self)
        }

        /// SE-0152 precedence: numeric on `(major, minor, patch ?? 0)`.
        @inlinable
        public static func < (lhs: Self, rhs: Self) -> Swift.Bool {
            if lhs.major != rhs.major { return lhs.major < rhs.major }
            if lhs.minor != rhs.minor { return lhs.minor < rhs.minor }
            let lp = lhs.patch?.underlying ?? 0
            let rp = rhs.patch?.underlying ?? 0
            return lp < rp
        }

        @inlinable
        static func position(_ offset: Swift.UInt) -> Text.Position {
            Text.Position(_unchecked: Ordinal(offset))
        }
    }
}
