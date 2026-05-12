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
import Time_Primitives_Core
import Version_Primitives

@Suite("Version.Calendar")
struct VersionCalendarTests {
    @Suite struct Construction {}
    @Suite struct Comparison {}
    @Suite struct RoundTrip {}
    @Suite struct ErrorCases {}
}

extension VersionCalendarTests.Construction {
    @Test
    func `Parses year-only`() throws(Version.Calendar.Error) {
        let v = try Version.Calendar(parsing: "2026")
        guard case .yearOnly(let year, let modifier) = v else {
            Issue.record("expected yearOnly case")
            return
        }
        #expect(year.rawValue == 2026)
        #expect(modifier == nil)
    }

    @Test
    func `Parses year-month`() throws(Version.Calendar.Error) {
        let v = try Version.Calendar(parsing: "24.04")
        guard case .yearMonth(let year, let month, _) = v else {
            Issue.record("expected yearMonth case")
            return
        }
        #expect(year.rawValue == 24)
        #expect(month.rawValue == 4)
    }

    @Test
    func `Parses full form`() throws(Version.Calendar.Error) {
        let v = try Version.Calendar(parsing: "2026.05.13")
        guard case .full(let year, let month, let micro, _) = v else {
            Issue.record("expected full case")
            return
        }
        #expect(year.rawValue == 2026)
        #expect(month.rawValue == 5)
        #expect(micro.underlying == 13)
    }

    @Test
    func `Parses with modifier`() throws(Version.Calendar.Error) {
        let v = try Version.Calendar(parsing: "2026.05.13-rc1")
        guard case .full(_, _, _, let modifier) = v else {
            Issue.record("expected full case")
            return
        }
        #expect(modifier == "rc1")
    }
}

extension VersionCalendarTests.Comparison {
    @Test
    func `Newer year is greater`() throws(Version.Calendar.Error) {
        let a = try Version.Calendar(parsing: "2025.12")
        let b = try Version.Calendar(parsing: "2026.01")
        #expect(a < b)
    }

    @Test
    func `Modifier-bearing orders lower than modifier-free`() throws(Version.Calendar.Error) {
        let pre = try Version.Calendar(parsing: "2026.05.13-rc1")
        let release = try Version.Calendar(parsing: "2026.05.13")
        #expect(pre < release)
    }

    @Test
    func `Different schemes compare numerically with zero-fill`() throws(Version.Calendar.Error) {
        let yearMonth = try Version.Calendar(parsing: "2026.05")
        let full = try Version.Calendar(parsing: "2026.05.0")
        // Same normalized tuple — neither orders before the other.
        #expect(!(yearMonth < full))
        #expect(!(full < yearMonth))
        // But scheme identity makes them non-equal.
        #expect(yearMonth != full)
    }
}

extension VersionCalendarTests.RoundTrip {
    @Test
    func `Year-only round-trips`() throws(Version.Calendar.Error) {
        let v = try Version.Calendar(parsing: "2026")
        #expect(v.description == "2026")
    }

    @Test
    func `Full form with modifier round-trips`() throws(Version.Calendar.Error) {
        let v = try Version.Calendar(parsing: "2026.05.13-rc1")
        #expect(v.description == "2026.05.13-rc1")
    }
}

extension VersionCalendarTests.ErrorCases {
    @Test
    func `Empty rejected`() {
        #expect(throws: Version.Calendar.Error.self) {
            try Version.Calendar(parsing: "")
        }
    }

    @Test
    func `Non-numeric rejected`() {
        #expect(throws: Version.Calendar.Error.self) {
            try Version.Calendar(parsing: "abc")
        }
    }

    @Test
    func `Empty modifier rejected`() {
        #expect(throws: Version.Calendar.Error.self) {
            try Version.Calendar(parsing: "2026.05.13-")
        }
    }

    @Test
    func `Four numeric components rejected`() {
        #expect(throws: Version.Calendar.Error.self) {
            try Version.Calendar(parsing: "2026.05.13.99")
        }
    }

    @Test
    func `Month out of range (>12) rejected via Time.Month validation`() {
        #expect(throws: Version.Calendar.Error.self) {
            try Version.Calendar(parsing: "2026.13.01")
        }
    }

    @Test
    func `Month zero rejected via Time.Month validation`() {
        #expect(throws: Version.Calendar.Error.self) {
            try Version.Calendar(parsing: "2026.00.01")
        }
    }
}
