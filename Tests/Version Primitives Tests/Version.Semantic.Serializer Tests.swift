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

import Parser_Primitives
import Serializer_Primitives
import Testing
import Version_Primitives

@Suite("Version.Semantic.Serializer")
struct VersionSemanticSerializerTests {
    @Test
    func `Serializes a bare version to bytes`() {
        let version = Version.Semantic(major: 1, minor: 2, patch: 3)
        var buffer: [Swift.UInt8] = []
        Version.Semantic.Serializer().serialize(version, into: &buffer)
        #expect(Swift.String(decoding: buffer, as: Swift.UTF8.self) == "1.2.3")
    }

    @Test
    func `Serializes with prerelease and build metadata`() throws(Version.Semantic.Error) {
        let version = try Version.Semantic(parsing: "1.2.3-alpha.1+sha.abc123")
        var buffer: [Swift.UInt8] = []
        Version.Semantic.Serializer().serialize(version, into: &buffer)
        #expect(Swift.String(decoding: buffer, as: Swift.UTF8.self) == "1.2.3-alpha.1+sha.abc123")
    }

    @Test
    func `Parser and Serializer round-trip`() throws(Version.Semantic.Error) {
        let inputs = [
            "0.0.0",
            "1.0.0",
            "1.2.3",
            "1.2.3-alpha",
            "1.2.3-alpha.1",
            "1.2.3-0.3.7",
            "1.2.3-x.7.z.92",
            "1.2.3+sha.abc",
            "1.2.3-rc.1+build.456",
            "10.20.30",
        ]
        for input in inputs {
            let parsed = try Version.Semantic(parsing: input)
            var buffer: [Swift.UInt8] = []
            Version.Semantic.Serializer().serialize(parsed, into: &buffer)
            let roundTripped = Swift.String(decoding: buffer, as: Swift.UTF8.self)
            #expect(roundTripped == input, "round-trip failure for \(input)")
        }
    }

    @Test
    func `Serializer output matches description`() throws(Version.Semantic.Error) {
        let version = try Version.Semantic(parsing: "2.0.0-rc.1+build.99")
        var buffer: [Swift.UInt8] = []
        Version.Semantic.Serializer().serialize(version, into: &buffer)
        #expect(Swift.String(decoding: buffer, as: Swift.UTF8.self) == version.description)
    }
}
