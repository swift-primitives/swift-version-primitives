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

@Suite struct `Version.Range Algebra Tests` {
    @Test
    func `Unbounded range is not empty`() {
        let range: Version.Range<Version.Semantic> = .all
        #expect(!range.isEmpty)
    }

    @Test
    func `Crossed bounds are empty`() {
        let range = Version.Range<Version.Semantic>(
            lowerBound: .inclusive(Version.Semantic(major: 2, minor: 0, patch: 0)),
            upperBound: .exclusive(Version.Semantic(major: 1, minor: 0, patch: 0))
        )
        #expect(range.isEmpty)
    }

    @Test
    func `Equal bounds, both inclusive, are non-empty singletons`() {
        let v = Version.Semantic(major: 1, minor: 0, patch: 0)
        let range = Version.Range<Version.Semantic>(
            lowerBound: .inclusive(v),
            upperBound: .inclusive(v)
        )
        #expect(!range.isEmpty)
    }

    @Test
    func `Equal bounds with one exclusive are empty`() {
        let v = Version.Semantic(major: 1, minor: 0, patch: 0)
        let range = Version.Range<Version.Semantic>(
            lowerBound: .inclusive(v),
            upperBound: .exclusive(v)
        )
        #expect(range.isEmpty)
    }

    @Test
    func `Intersection of overlapping ranges`() {
        let a = Version.Range<Version.Semantic>(
            lowerBound: .inclusive(Version.Semantic(major: 1, minor: 0, patch: 0)),
            upperBound: .exclusive(Version.Semantic(major: 2, minor: 0, patch: 0))
        )
        let b = Version.Range<Version.Semantic>(
            lowerBound: .inclusive(Version.Semantic(major: 1, minor: 5, patch: 0)),
            upperBound: .exclusive(Version.Semantic(major: 3, minor: 0, patch: 0))
        )
        let intersected = a.intersection(b)
        // [1.5.0, 2.0.0)
        #expect(intersected.contains(Version.Semantic(major: 1, minor: 5, patch: 0)))
        #expect(intersected.contains(Version.Semantic(major: 1, minor: 99, patch: 99)))
        #expect(!intersected.contains(Version.Semantic(major: 1, minor: 4, patch: 99)))
        #expect(!intersected.contains(Version.Semantic(major: 2, minor: 0, patch: 0)))
    }

    @Test
    func `Disjoint ranges intersect to empty`() {
        let a = Version.Range<Version.Semantic>.upToNextMajor(from: Version.Semantic(major: 1, minor: 0, patch: 0))
        let b = Version.Range<Version.Semantic>.upToNextMajor(from: Version.Semantic(major: 3, minor: 0, patch: 0))
        // Version.Range.intersection, not Swift.Set.intersection.
        // swiftlint:disable:next is_disjoint
        #expect(a.intersection(b).isEmpty)
        #expect(!a.overlaps(b))
    }

    @Test
    func `Strict subset detected — caret 1 inside 1-3`() {
        let inner = Version.Range<Version.Semantic>.upToNextMajor(from: Version.Semantic(major: 1, minor: 0, patch: 0))
        let outer = Version.Range<Version.Semantic>(
            lowerBound: .inclusive(Version.Semantic(major: 1, minor: 0, patch: 0)),
            upperBound: .exclusive(Version.Semantic(major: 3, minor: 0, patch: 0))
        )
        #expect(inner.isSubset(of: outer))
        #expect(outer.isSuperset(of: inner))
        #expect(outer.contains(inner))
        #expect(!inner.contains(outer))
    }

    @Test
    func `Identical ranges are mutual subsets`() {
        let r = Version.Range<Version.Semantic>.upToNextMajor(from: Version.Semantic(major: 1, minor: 0, patch: 0))
        #expect(r.isSubset(of: r))
        #expect(r.isSuperset(of: r))
        #expect(r.contains(r))
    }

    @Test
    func `Empty range is subset of every range`() {
        let empty = Version.Range<Version.Semantic>(
            lowerBound: .inclusive(Version.Semantic(major: 2, minor: 0, patch: 0)),
            upperBound: .exclusive(Version.Semantic(major: 1, minor: 0, patch: 0))
        )
        let any: Version.Range<Version.Semantic> = .all
        let caret = Version.Range<Version.Semantic>.upToNextMajor(from: Version.Semantic(major: 1, minor: 0, patch: 0))
        #expect(empty.isSubset(of: any))
        #expect(empty.isSubset(of: caret))
        #expect(empty.isSubset(of: empty))
    }

    @Test
    func `Unbounded is superset of any bounded range`() {
        let any: Version.Range<Version.Semantic> = .all
        let caret = Version.Range<Version.Semantic>.upToNextMajor(from: Version.Semantic(major: 1, minor: 0, patch: 0))
        #expect(any.isSuperset(of: caret))
        #expect(caret.isSubset(of: any))
        #expect(!any.isSubset(of: caret))
    }

    @Test
    func `Inclusive vs exclusive boundary distinguishes coverage`() {
        let one = Version.Semantic(major: 1, minor: 0, patch: 0)
        let two = Version.Semantic(major: 2, minor: 0, patch: 0)
        // [1.0.0, 2.0.0)
        let halfOpen = Version.Range<Version.Semantic>(
            lowerBound: .inclusive(one),
            upperBound: .exclusive(two)
        )
        // (1.0.0, 2.0.0]
        let openClosed = Version.Range<Version.Semantic>(
            lowerBound: .exclusive(one),
            upperBound: .inclusive(two)
        )
        // Neither is a subset of the other — boundary versions
        // differ on each side.
        #expect(!halfOpen.isSubset(of: openClosed))
        #expect(!openClosed.isSubset(of: halfOpen))
    }
}
