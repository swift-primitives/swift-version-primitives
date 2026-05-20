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

internal import Ordinal_Primitives
public import Byte_Parser_Primitives
internal import Byte_Primitives_Standard_Library_Integration
internal import Parser_Primitives
public import Tagged_Primitives
public import Text_Primitives

extension Version {
    /// Semantic Versioning 2.0.0 typed representation.
    ///
    /// Implements the spec at https://semver.org/. A semantic
    /// version has five components:
    ///
    /// ```
    /// MAJOR.MINOR.PATCH[-prerelease][+build]
    /// ```
    ///
    /// - `MAJOR`, `MINOR`, `PATCH`: non-negative integers with no
    ///   leading zeros (§2).
    /// - Pre-release identifiers: dot-separated tokens after `-`,
    ///   each `[0-9A-Za-z-]+` (§9). Precedence follows §11.4.
    /// - Build-metadata identifiers: dot-separated tokens after
    ///   `+`, each `[0-9A-Za-z-]+` (§10). Excluded from precedence.
    ///
    /// Construction validates the input at the type system:
    ///
    /// ```swift
    /// let v = try Version.Semantic("1.2.3-alpha.1+sha.abc123")
    /// ```
    ///
    /// Equality and comparison follow §11 precedence (build
    /// metadata is excluded per §10 — two versions differing only
    /// in build metadata compare equal and have the same hash).
    public struct Semantic: Swift.Sendable, Swift.Hashable, Swift.Comparable, Swift.CustomStringConvertible {
        /// The MAJOR version component.
        ///
        /// Typed as ``Version/Semantic/Major/Value`` (a phantom-tagged
        /// `Swift.UInt`) so MAJOR cannot be swapped with MINOR or
        /// PATCH at call sites.
        public let major: Major.Value

        /// The MINOR version component.
        ///
        /// Typed as ``Version/Semantic/Minor/Value`` (a phantom-tagged
        /// `Swift.UInt`) so MINOR cannot be swapped with MAJOR or
        /// PATCH at call sites.
        public let minor: Minor.Value

        /// The PATCH version component.
        ///
        /// Typed as ``Version/Semantic/Patch/Value`` (a phantom-tagged
        /// `Swift.UInt`) so PATCH cannot be swapped with MAJOR or
        /// MINOR at call sites.
        public let patch: Patch.Value

        /// Pre-release identifiers per SemVer 2.0.0 §9.
        ///
        /// Stored in occurrence order. Empty if the version has no
        /// pre-release suffix.
        public let preReleaseIdentifiers: [Identifier]

        /// Build-metadata identifiers per SemVer 2.0.0 §10.
        ///
        /// Stored in occurrence order. Empty if the version has no
        /// build-metadata suffix. **Excluded from equality and
        /// comparison** per §10.
        public let buildMetadataIdentifiers: [Swift.String]

        /// Constructs a version from its components directly.
        ///
        /// Trust the caller for component validity — callers
        /// handling untrusted input MUST use the throwing string
        /// parser ``init(parsing:)`` instead.
        public init(
            major: Major.Value,
            minor: Minor.Value,
            patch: Patch.Value,
            preReleaseIdentifiers: [Identifier] = [],
            buildMetadataIdentifiers: [Swift.String] = []
        ) {
            self.major = major
            self.minor = minor
            self.patch = patch
            self.preReleaseIdentifiers = preReleaseIdentifiers
            self.buildMetadataIdentifiers = buildMetadataIdentifiers
        }

        /// Parses a SemVer 2.0.0 version string with typed throws.
        ///
        /// Strict variant: the entire string must form a single
        /// valid SemVer 2.0.0 version. Trailing bytes after a valid
        /// version run cause a `Version.Semantic.Error` — use
        /// ``Version/Semantic/Parser`` directly to consume only the
        /// leading SemVer token within a larger byte stream.
        ///
        /// - Throws: ``Version/Semantic/Error`` cases describing
        ///   which spec rule the input violated.
        public init(parsing versionString: Swift.String) throws(Version.Semantic.Error) {
            let totalBytes = Swift.UInt(versionString.utf8.count)
            var firstNonASCII: Swift.UInt?
            for (offset, byte) in versionString.utf8.enumerated() where byte >= 0x80 {
                firstNonASCII = Swift.UInt(offset)
                break
            }
            if let firstNonASCII {
                throw .nonASCIICharacters(
                    input: versionString,
                    range: Text.Range(
                        start: Self.position(firstNonASCII),
                        end: Self.position(firstNonASCII + 1)
                    )
                )
            }
            var input = Byte.Input(utf8: versionString)
            self = try Version.Semantic.Parser().parse(&input)
            if !input.isEmpty {
                let remaining = Swift.UInt(input.count)
                let consumed = totalBytes - remaining
                let trailing = Swift.String(decoding: input, as: Swift.UTF8.self)
                let trailingRange = Text.Range(
                    start: Self.position(consumed),
                    end: Self.position(totalBytes)
                )
                if input.first == 0x2E {
                    throw .invalidVersionCoreIdentifierCount(
                        input: versionString,
                        found: Self.countDots(in: versionString) + 1,
                        range: trailingRange
                    )
                }
                throw .invalidVersionCoreIdentifier(
                    input: versionString,
                    identifier: trailing,
                    range: trailingRange
                )
            }
        }

        @inlinable
        static func position(_ offset: Swift.UInt) -> Text.Position {
            Text.Position(_unchecked: Ordinal(offset))
        }

        // Total dot count across the input string (used only to
        // populate the §2 error's `found` parameter when trailing
        // dots indicate a 4+-component core).
        private static func countDots(in s: Swift.String) -> Swift.Int {
            var count = 0
            for byte in s.utf8 where byte == 0x2E {
                count += 1
            }
            return count
        }

        /// Canonical SemVer 2.0.0 spelling: `MAJOR.MINOR.PATCH`,
        /// followed by `-<pre>` if pre-release identifiers are
        /// present, followed by `+<build>` if build-metadata
        /// identifiers are present.
        ///
        /// Delegates to ``Version/Semantic/Serializer`` for single-
        /// source-of-truth formatting symmetric with the byte-stream
        /// parser.
        public var description: Swift.String {
            var buffer: [Byte] = []
            Version.Semantic.Serializer<[Byte]>().serialize(self, into: &buffer)
            return Swift.String(decoding: buffer, as: Swift.UTF8.self)
        }

        // SemVer 2.0.0 §10: equality and hashing EXCLUDE build
        // metadata. Two versions that differ only in build metadata
        // compare equal.

        /// SemVer 2.0.0 §10 equality — build metadata is excluded.
        public static func == (lhs: Self, rhs: Self) -> Bool {
            lhs.major == rhs.major
                && lhs.minor == rhs.minor
                && lhs.patch == rhs.patch
                && lhs.preReleaseIdentifiers == rhs.preReleaseIdentifiers
        }

        /// SemVer 2.0.0 §10 hash — build metadata is excluded.
        public func hash(into hasher: inout Swift.Hasher) {
            hasher.combine(self.major)
            hasher.combine(self.minor)
            hasher.combine(self.patch)
            hasher.combine(self.preReleaseIdentifiers)
        }

        // SemVer 2.0.0 §11 precedence:
        //
        // 1. Compare MAJOR, MINOR, PATCH numerically.
        // 2. A version with pre-release identifiers has LOWER
        //    precedence than a version without (§11.3).
        // 3. Precedence among pre-release versions: compare
        //    identifiers left-to-right per §11.4.

        /// SemVer 2.0.0 §11 precedence ordering.
        public static func < (lhs: Self, rhs: Self) -> Bool {
            if lhs.major != rhs.major { return lhs.major < rhs.major }
            if lhs.minor != rhs.minor { return lhs.minor < rhs.minor }
            if lhs.patch != rhs.patch { return lhs.patch < rhs.patch }

            // §11.3: a version with pre-release identifiers has
            // LOWER precedence than the same MAJOR.MINOR.PATCH
            // without them.
            switch (lhs.preReleaseIdentifiers.isEmpty, rhs.preReleaseIdentifiers.isEmpty) {
            case (true, true): return false

            case (true, false): return false  // lhs is release, rhs is pre-release → lhs > rhs

            case (false, true): return true  // lhs is pre-release, rhs is release → lhs < rhs

            case (false, false):
                return Self.compareIdentifiers(lhs.preReleaseIdentifiers, rhs.preReleaseIdentifiers)
            }
        }

        // SemVer 2.0.0 §11.4: compare pre-release identifiers
        // left-to-right; shorter pre-release wins ties on common
        // prefix.
        private static func compareIdentifiers(_ lhs: [Identifier], _ rhs: [Identifier]) -> Bool {
            for (l, r) in zip(lhs, rhs) {
                if l == r { continue }
                return l < r
            }
            // All compared identifiers equal — shorter has lower
            // precedence per §11.4.
            return lhs.count < rhs.count
        }

    }
}
