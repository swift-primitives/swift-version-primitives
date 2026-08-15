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
// ``Version/Tools/Serializer`` directly.
//
// `Codable`'s protocol requirements force existential coder parameters
// and untyped `throws` at the exact `init(from:)`/`encode(to:)` witness
// signatures below; both central rules already carve out that stdlib
// witness position natively (swift-institute/.github#219), so no local
// disable is needed here.

#if !hasFeature(Embedded)
    extension Version.Tools: Codable {
        /// Decodes from the canonical SE-0152 string form.
        @inlinable
        public init(from decoder: any Decoder) throws {
            let container = try decoder.singleValueContainer()
            let string = try container.decode(Swift.String.self)
            do throws(Self.Error) {
                self = try Version.Tools(parsing: string)
            } catch {
                throw DecodingError.dataCorruptedError(
                    in: container,
                    debugDescription: "Invalid tools-version string '\(string)': \(error)"
                )
            }
        }

        /// Encodes as the canonical SE-0152 string form.
        @inlinable
        public func encode(to encoder: any Encoder) throws {
            var container = encoder.singleValueContainer()
            try container.encode(self.description)
        }
    }
#endif
