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

@Suite("Version.Tools Tagged components")
struct VersionToolsTaggedTests {
    @Test
    func `Integer literal flows through to tagged component`() {
        let major: Version.Tools.Major.Value = 6
        let minor: Version.Tools.Minor.Value = 3
        let patch: Version.Tools.Patch.Value = 1
        #expect(major.underlying == 6)
        #expect(minor.underlying == 3)
        #expect(patch.underlying == 1)
    }

    @Test
    func `Component init accepts integer literals`() {
        let v = Version.Tools(major: 6, minor: 3, patch: 1)
        #expect(v.major.underlying == 6)
        #expect(v.minor.underlying == 3)
        #expect(v.patch?.underlying == 1)
    }

    @Test
    func `Patch-absent construction via integer literals`() {
        let v = Version.Tools(major: 6, minor: 3)
        #expect(v.patch == nil)
    }

    @Test
    func `Tag namespaces are type-distinct`() {
        // Compile-time witness: each tools component has its own
        // type. The runtime metatype-equality assertion catches a
        // regression that collapsed the tag distinction (e.g.,
        // accidentally typealiasing Patch.Value to Minor.Value).
        #expect(Version.Tools.Major.Value.self != Version.Tools.Minor.Value.self)
        #expect(Version.Tools.Minor.Value.self != Version.Tools.Patch.Value.self)
        #expect(Version.Tools.Major.Value.self != Version.Tools.Patch.Value.self)
    }

    @Test
    func `Tools components are distinct from Semantic components`() {
        // Cross-kind type discrimination: a Tools.Major.Value
        // cannot be confused with a Semantic.Major.Value at the
        // type level, even though both wrap UInt with a "Major"
        // role.
        #expect(Version.Tools.Major.Value.self != Version.Semantic.Major.Value.self)
        #expect(Version.Tools.Minor.Value.self != Version.Semantic.Minor.Value.self)
        #expect(Version.Tools.Patch.Value.self != Version.Semantic.Patch.Value.self)
    }
}
