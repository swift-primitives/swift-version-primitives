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

import Testing
import Version_Primitives

@Suite("Version.Semantic.Bumped")
struct VersionSemanticBumpedTests {
    @Test
    func `Major bump zeros minor and patch`() {
        let v = Version.Semantic(major: 1, minor: 2, patch: 3)
        let bumped = v.bumped.major
        #expect(bumped.major.underlying == 2)
        #expect(bumped.minor.underlying == 0)
        #expect(bumped.patch.underlying == 0)
    }

    @Test
    func `Minor bump zeros patch, preserves major`() {
        let v = Version.Semantic(major: 1, minor: 2, patch: 3)
        let bumped = v.bumped.minor
        #expect(bumped.major.underlying == 1)
        #expect(bumped.minor.underlying == 3)
        #expect(bumped.patch.underlying == 0)
    }

    @Test
    func `Patch bump preserves major and minor`() {
        let v = Version.Semantic(major: 1, minor: 2, patch: 3)
        let bumped = v.bumped.patch
        #expect(bumped.major.underlying == 1)
        #expect(bumped.minor.underlying == 2)
        #expect(bumped.patch.underlying == 4)
    }

    @Test
    func `Bumping drops pre-release and build metadata`() throws(Version.Semantic.Error) {
        let v = try Version.Semantic(parsing: "1.2.3-rc.1+build.42")
        let bumped = v.bumped.patch
        #expect(bumped.preReleaseIdentifiers.isEmpty)
        #expect(bumped.buildMetadataIdentifiers.isEmpty)
        #expect(bumped.description == "1.2.4")
    }

    @Test
    func `Bumping is total ordering: bumped > self`() {
        let v = Version.Semantic(major: 1, minor: 2, patch: 3)
        #expect(v.bumped.patch > v)
        #expect(v.bumped.minor > v.bumped.patch)
        #expect(v.bumped.major > v.bumped.minor)
    }
}
