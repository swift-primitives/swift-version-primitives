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
import Testing
import Version_Primitives

@Suite("Version.Semantic.Parser")
struct VersionSemanticParserTests {
    @Test
    func `Parses a bare version from byte input`() throws(Version.Semantic.Error) {
        var input = Parser.Input.Bytes(utf8: "1.2.3")
        let version = try Version.Semantic.Parser().parse(&input)
        #expect(version.major == 1)
        #expect(version.minor == 2)
        #expect(version.patch == 3)
    }

    @Test
    func `Parses pre-release and build metadata from byte input`() throws(Version.Semantic.Error) {
        var input = Parser.Input.Bytes(utf8: "1.2.3-alpha.1+sha.abc123")
        let version = try Version.Semantic.Parser().parse(&input)
        #expect(version.preReleaseIdentifiers == [.alphanumeric("alpha"), .numeric(1)])
        #expect(version.buildMetadataIdentifiers == ["sha", "abc123"])
    }

    @Test
    func `Greedy consumption stops at non-version byte`() throws(Version.Semantic.Error) {
        var input = Parser.Input.Bytes(utf8: "1.2.3 trailing")
        let version = try Version.Semantic.Parser().parse(&input)
        #expect(version.major == 1)
        // The space and trailing bytes remain in the input slice.
        #expect(input.first == 0x20)  // ' '
    }

    @Test
    func `Invalid version syntax throws typed error`() {
        var input = Parser.Input.Bytes(utf8: "1.2")
        #expect(throws: Version.Semantic.Error.self) {
            _ = try Version.Semantic.Parser().parse(&input)
        }
    }

    @Test
    func `Empty input throws typed error`() {
        var input = Parser.Input.Bytes(utf8: "")
        #expect(throws: Version.Semantic.Error.self) {
            _ = try Version.Semantic.Parser().parse(&input)
        }
    }
}
