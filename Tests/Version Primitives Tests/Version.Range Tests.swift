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

@Suite("Version.Range")
struct VersionRangeTests {
    @Test
    func `Unbounded range contains every version`() {
        let range: Version.Range<Version.Semantic> = .all
        #expect(range.contains(Version.Semantic(major: 0, minor: 0, patch: 0)))
        #expect(range.contains(Version.Semantic(major: 999, minor: 999, patch: 999)))
    }

    @Test
    func `Exact range contains only the exact version`() {
        let target = Version.Semantic(major: 1, minor: 2, patch: 3)
        let range: Version.Range<Version.Semantic> = .exact(target)
        #expect(range.contains(target))
        #expect(!range.contains(Version.Semantic(major: 1, minor: 2, patch: 2)))
        #expect(!range.contains(Version.Semantic(major: 1, minor: 2, patch: 4)))
    }

    @Test
    func `Inclusive lower / exclusive upper is half-open`() {
        let range = Version.Range<Version.Semantic>(
            lowerBound: .inclusive(Version.Semantic(major: 1, minor: 0, patch: 0)),
            upperBound: .exclusive(Version.Semantic(major: 2, minor: 0, patch: 0))
        )
        #expect(range.contains(Version.Semantic(major: 1, minor: 0, patch: 0)))
        #expect(range.contains(Version.Semantic(major: 1, minor: 99, patch: 99)))
        #expect(!range.contains(Version.Semantic(major: 2, minor: 0, patch: 0)))
        #expect(!range.contains(Version.Semantic(major: 0, minor: 99, patch: 99)))
    }

    @Test
    func `Exclusive lower excludes the lower bound itself`() {
        let range = Version.Range<Version.Semantic>(
            lowerBound: .exclusive(Version.Semantic(major: 1, minor: 0, patch: 0)),
            upperBound: .unbounded
        )
        #expect(!range.contains(Version.Semantic(major: 1, minor: 0, patch: 0)))
        #expect(range.contains(Version.Semantic(major: 1, minor: 0, patch: 1)))
    }

    @Test
    func `upToNextMajor caret semantics`() {
        let range: Version.Range<Version.Semantic> = .upToNextMajor(from: Version.Semantic(major: 1, minor: 2, patch: 3))
        #expect(range.contains(Version.Semantic(major: 1, minor: 2, patch: 3)))
        #expect(range.contains(Version.Semantic(major: 1, minor: 99, patch: 99)))
        #expect(!range.contains(Version.Semantic(major: 2, minor: 0, patch: 0)))
        #expect(!range.contains(Version.Semantic(major: 1, minor: 2, patch: 2)))
    }

    @Test
    func `upToNextMinor tilde semantics`() {
        let range: Version.Range<Version.Semantic> = .upToNextMinor(from: Version.Semantic(major: 1, minor: 2, patch: 3))
        #expect(range.contains(Version.Semantic(major: 1, minor: 2, patch: 3)))
        #expect(range.contains(Version.Semantic(major: 1, minor: 2, patch: 99)))
        #expect(!range.contains(Version.Semantic(major: 1, minor: 3, patch: 0)))
        #expect(!range.contains(Version.Semantic(major: 1, minor: 2, patch: 2)))
    }
}
