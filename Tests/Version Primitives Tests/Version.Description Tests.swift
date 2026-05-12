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

@Suite("Description / DebugDescription")
struct VersionDescriptionTests {
    @Suite struct RangeBound {}
    @Suite struct Range {}
    @Suite struct Set {}
    @Suite struct Phase {}
    @Suite struct Calendar {}
}

extension VersionDescriptionTests.RangeBound {
    @Test
    func `Unbounded prints as 'unbounded'`() {
        let bound: Version.Range<Version.Semantic>.Bound = .unbounded
        #expect(bound.description == "unbounded")
    }

    @Test
    func `Inclusive prints wrapping value`() {
        let v = Version.Semantic(major: 1, minor: 0, patch: 0)
        let bound: Version.Range<Version.Semantic>.Bound = .inclusive(v)
        #expect(bound.description == "inclusive(1.0.0)")
    }

    @Test
    func `Exclusive prints wrapping value`() {
        let v = Version.Semantic(major: 2, minor: 0, patch: 0)
        let bound: Version.Range<Version.Semantic>.Bound = .exclusive(v)
        #expect(bound.description == "exclusive(2.0.0)")
    }
}

extension VersionDescriptionTests.Range {
    @Test
    func `Unbounded range prints interval notation`() {
        let range: Version.Range<Version.Semantic> = .all
        #expect(range.description == "(-∞, +∞)")
    }

    @Test
    func `Exact range prints closed interval`() {
        let v = Version.Semantic(major: 1, minor: 2, patch: 3)
        let range: Version.Range<Version.Semantic> = .exact(v)
        #expect(range.description == "[1.2.3, 1.2.3]")
    }

    @Test
    func `Half-open caret range prints canonical form`() {
        let range = Version.Range<Version.Semantic>.upToNextMajor(from: Version.Semantic(major: 1, minor: 0, patch: 0))
        #expect(range.description == "[1.0.0, 2.0.0)")
    }

    @Test
    func `Mixed bounds — exclusive lower, inclusive upper`() {
        let range = Version.Range<Version.Semantic>(
            lowerBound: .exclusive(Version.Semantic(major: 1, minor: 0, patch: 0)),
            upperBound: .inclusive(Version.Semantic(major: 2, minor: 0, patch: 0))
        )
        #expect(range.description == "(1.0.0, 2.0.0]")
    }

    @Test
    func `One-sided unbounded prints with infinity symbol`() {
        let upperOpen = Version.Range<Version.Semantic>(
            lowerBound: .inclusive(Version.Semantic(major: 1, minor: 0, patch: 0)),
            upperBound: .unbounded
        )
        #expect(upperOpen.description == "[1.0.0, +∞)")

        let lowerOpen = Version.Range<Version.Semantic>(
            lowerBound: .unbounded,
            upperBound: .exclusive(Version.Semantic(major: 2, minor: 0, patch: 0))
        )
        #expect(lowerOpen.description == "(-∞, 2.0.0)")
    }
}

extension VersionDescriptionTests.Set {
    @Test
    func `Empty prints as set-theoretic empty symbol`() {
        let set: Version.Set<Version.Semantic> = .empty
        #expect(set.description == "∅")
        #expect(set.debugDescription == ".empty")
    }

    @Test
    func `Any prints as wildcard`() {
        let set: Version.Set<Version.Semantic> = .any
        #expect(set.description == "*")
        #expect(set.debugDescription == ".any")
    }

    @Test
    func `Exact prints as singleton notation`() {
        let v = Version.Semantic(major: 1, minor: 2, patch: 3)
        let set: Version.Set<Version.Semantic> = .exact(v)
        #expect(set.description == "{1.2.3}")
        #expect(set.debugDescription == ".exact(1.2.3)")
    }

    @Test
    func `Range delegates description, labels in debug`() {
        let interval = Version.Range<Version.Semantic>.upToNextMajor(from: Version.Semantic(major: 1, minor: 0, patch: 0))
        let set: Version.Set<Version.Semantic> = .range(interval)
        #expect(set.description == "[1.0.0, 2.0.0)")
        #expect(set.debugDescription == ".range([1.0.0, 2.0.0))")
    }

    @Test
    func `Union joins members with ∪`() {
        let v1 = Version.Semantic(major: 1, minor: 0, patch: 0)
        let v2 = Version.Semantic(major: 2, minor: 0, patch: 0)
        let set: Version.Set<Version.Semantic> = .union([.exact(v1), .exact(v2)])
        #expect(set.description == "({1.0.0} ∪ {2.0.0})")
        #expect(set.debugDescription == ".union([.exact(1.0.0), .exact(2.0.0)])")
    }

    @Test
    func `Empty union prints as empty; debug retains union shape`() {
        let set: Version.Set<Version.Semantic> = .union([])
        #expect(set.description == "∅")
        #expect(set.debugDescription == ".union([])")
    }

    @Test
    func `Singleton union prints as the single member`() {
        let v = Version.Semantic(major: 1, minor: 0, patch: 0)
        let set: Version.Set<Version.Semantic> = .union([.exact(v)])
        #expect(set.description == "{1.0.0}")
        #expect(set.debugDescription == ".union([.exact(1.0.0)])")
    }
}

extension VersionDescriptionTests.Phase {
    @Test
    func `Initial prints simple name`() {
        #expect(Version.Semantic.Phase.initial.description == "initial")
        #expect(Version.Semantic.Phase.initial.debugDescription == ".initial")
    }

    @Test
    func `Stable prints simple name`() {
        #expect(Version.Semantic.Phase.stable.description == "stable")
        #expect(Version.Semantic.Phase.stable.debugDescription == ".stable")
    }
}

extension VersionDescriptionTests.Calendar {
    @Test
    func `Year-only debug retains case label`() throws(Version.Calendar.Error) {
        let v = try Version.Calendar(parsing: "2026")
        #expect(v.debugDescription == ".yearOnly(year: 2026, modifier: nil)")
    }

    @Test
    func `Year-month debug retains case label`() throws(Version.Calendar.Error) {
        let v = try Version.Calendar(parsing: "2026.05")
        #expect(v.debugDescription == ".yearMonth(year: 2026, month: 5, modifier: nil)")
    }

    @Test
    func `Full debug retains case label`() throws(Version.Calendar.Error) {
        let v = try Version.Calendar(parsing: "2026.05.13")
        #expect(v.debugDescription == ".full(year: 2026, month: 5, micro: 13, modifier: nil)")
    }

    @Test
    func `Modifier round-trips through debug as quoted string`() throws(Version.Calendar.Error) {
        let v = try Version.Calendar(parsing: "2026.05.13-rc1")
        #expect(v.debugDescription == ".full(year: 2026, month: 5, micro: 13, modifier: \"rc1\")")
    }

    @Test
    func `Debug distinguishes scheme identity that description erases`() throws(Version.Calendar.Error) {
        // 2026.05 (yearMonth) and 2026.05.0 (full) produce the same
        // normalized tuple but the debug form preserves the scheme.
        let yearMonth = try Version.Calendar(parsing: "2026.05")
        let full = try Version.Calendar(parsing: "2026.05.0")
        #expect(yearMonth.debugDescription != full.debugDescription)
    }
}
