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

// Codable conformance is excluded from Embedded Swift — `Codable`
// depends on stdlib protocols and runtime infrastructure that the
// Embedded mode does not ship. Consumers needing transport
// serialization in Embedded environments use
// ``Version/Semantic/Serializer`` directly.
//
// `Codable`'s protocol requirements force existential coder
// parameters and untyped `throws`; both rules are deliberately
// exempted for this file's conformance block.

// swiftlint:disable no_any_protocol_existential typed_throws_required
#if !hasFeature(Embedded)
    extension Version.Semantic: Codable {
        /// Decodes from the canonical SemVer 2.0.0 string form.
        @inlinable
        public init(from decoder: any Decoder) throws {
            let container = try decoder.singleValueContainer()
            let string = try container.decode(Swift.String.self)
            do {
                self = try Version.Semantic(string)
            } catch let error as Self.Error {
                throw DecodingError.dataCorruptedError(
                    in: container,
                    debugDescription: "Invalid SemVer 2.0.0 string '\(string)': \(error)"
                )
            }
        }

        /// Encodes as the canonical SemVer 2.0.0 string form.
        @inlinable
        public func encode(to encoder: any Encoder) throws {
            var container = encoder.singleValueContainer()
            try container.encode(self.description)
        }
    }
#endif
// swiftlint:enable no_any_protocol_existential typed_throws_required
