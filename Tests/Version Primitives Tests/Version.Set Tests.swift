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

@Suite("Version.Set")
struct VersionSetTests {
    @Test
    func `Empty set contains no version`() {
        let set: Version.Set<Version.Semantic> = .empty
        #expect(!set.contains(Version.Semantic(major: 1, minor: 0, patch: 0)))
    }

    @Test
    func `Any set contains every version`() {
        let set: Version.Set<Version.Semantic> = .any
        #expect(set.contains(Version.Semantic(major: 0, minor: 0, patch: 0)))
        #expect(set.contains(Version.Semantic(major: 999, minor: 999, patch: 999)))
    }

    @Test
    func `Exact set matches one version`() {
        let target = Version.Semantic(major: 1, minor: 2, patch: 3)
        let set: Version.Set<Version.Semantic> = .exact(target)
        #expect(set.contains(target))
        #expect(!set.contains(Version.Semantic(major: 1, minor: 2, patch: 2)))
    }

    @Test
    func `Range set matches the interval`() {
        let set: Version.Set<Version.Semantic> = .range(.upToNextMajor(from: Version.Semantic(major: 1, minor: 0, patch: 0)))
        #expect(set.contains(Version.Semantic(major: 1, minor: 99, patch: 99)))
        #expect(!set.contains(Version.Semantic(major: 2, minor: 0, patch: 0)))
    }

    @Test
    func `Union matches any member`() {
        let set: Version.Set<Version.Semantic> = .union([
            .exact(Version.Semantic(major: 1, minor: 0, patch: 0)),
            .range(.upToNextMajor(from: Version.Semantic(major: 3, minor: 0, patch: 0))),
        ])
        #expect(set.contains(Version.Semantic(major: 1, minor: 0, patch: 0)))
        #expect(set.contains(Version.Semantic(major: 3, minor: 5, patch: 0)))
        #expect(!set.contains(Version.Semantic(major: 2, minor: 0, patch: 0)))
        #expect(!set.contains(Version.Semantic(major: 4, minor: 0, patch: 0)))
    }

    @Test
    func `Empty union matches nothing`() {
        let set: Version.Set<Version.Semantic> = .union([])
        #expect(!set.contains(Version.Semantic(major: 1, minor: 0, patch: 0)))
    }
}
