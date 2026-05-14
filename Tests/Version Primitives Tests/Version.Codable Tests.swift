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

// JSON Encoder/Decoder are Foundation-bound and use untyped throws via the
// Codable protocol — both rules are deliberately exempted across this file.
// swiftlint:disable no_foundation_import_warning typed_throws_required
import Foundation
import Testing
import Version_Primitives

@Suite("Codable round-trips")
struct VersionCodableTests {
    @Test
    func `Semantic round-trips through JSON`() throws {
        let original = try Version.Semantic("1.2.3-rc.1+build.456")
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(Version.Semantic.self, from: data)
        #expect(decoded == original)
    }

    @Test
    func `Tools round-trips through JSON preserving patch absence`() throws {
        let original = try Version.Tools(parsing: "6.3")
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(Version.Tools.self, from: data)
        #expect(decoded == original)
        #expect(decoded.patch == nil)
    }

    @Test
    func `Calendar round-trips through JSON preserving scheme`() throws {
        let original = try Version.Calendar(parsing: "2026.05.13-rc1")
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(Version.Calendar.self, from: data)
        #expect(decoded == original)
    }

    @Test
    func `Semantic encodes as a single string value`() throws {
        let v = try Version.Semantic("1.0.0")
        let data = try JSONEncoder().encode(v)
        let string = String(decoding: data, as: UTF8.self)
        #expect(string == "\"1.0.0\"")
    }

    @Test
    func `Decoding invalid string throws DecodingError`() {
        let data = Data("\"not a version\"".utf8)
        #expect(throws: DecodingError.self) {
            _ = try JSONDecoder().decode(Version.Semantic.self, from: data)
        }
    }
}
// swiftlint:enable no_foundation_import_warning typed_throws_required
