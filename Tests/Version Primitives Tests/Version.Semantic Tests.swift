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

@Suite("Version.Semantic")
struct VersionSemanticTests {
    @Suite struct Construction {}
    @Suite struct Equality {}
    @Suite struct Precedence {}
    @Suite struct Description {}
    @Suite struct ErrorCases {}
}

// MARK: - Construction

extension VersionSemanticTests.Construction {
    @Test
    func `Parses bare MAJOR.MINOR.PATCH`() throws(Version.Semantic.Error) {
        let v = try Version.Semantic("1.2.3")
        #expect(v.major == 1)
        #expect(v.minor == 2)
        #expect(v.patch == 3)
        #expect(v.preReleaseIdentifiers.isEmpty)
        #expect(v.buildMetadataIdentifiers.isEmpty)
    }

    @Test
    func `Parses with prerelease identifiers`() throws(Version.Semantic.Error) {
        let v = try Version.Semantic("1.0.0-alpha.1")
        #expect(v.major == 1)
        #expect(v.minor == 0)
        #expect(v.patch == 0)
        #expect(v.preReleaseIdentifiers == [.alphanumeric("alpha"), .numeric(1)])
        #expect(v.buildMetadataIdentifiers.isEmpty)
    }

    @Test
    func `Parses with build metadata`() throws(Version.Semantic.Error) {
        let v = try Version.Semantic("1.0.0+sha.abc123")
        #expect(v.buildMetadataIdentifiers == ["sha", "abc123"])
    }

    @Test
    func `Parses with both prerelease and build metadata`() throws(Version.Semantic.Error) {
        let v = try Version.Semantic("1.2.3-rc.1+build.456")
        #expect(v.major == 1)
        #expect(v.preReleaseIdentifiers == [.alphanumeric("rc"), .numeric(1)])
        #expect(v.buildMetadataIdentifiers == ["build", "456"])
    }

    @Test
    func `Component init bypasses parser`() {
        let v = Version.Semantic(major: 2, minor: 0, patch: 0)
        #expect(v.major == 2)
        #expect(v.minor == 0)
        #expect(v.patch == 0)
    }

    @Test
    func `bare positional throwing init rejects invalid input`() {
        #expect(throws: Version.Semantic.Error.self) {
            try Version.Semantic("not a version")
        }
    }
}

// MARK: - Equality

extension VersionSemanticTests.Equality {
    @Test
    func `Identical versions compare equal`() throws(Version.Semantic.Error) {
        let a = try Version.Semantic("1.2.3")
        let b = try Version.Semantic("1.2.3")
        #expect(a == b)
    }

    @Test
    func `Build metadata is excluded from equality (SemVer §10)`() throws(Version.Semantic.Error) {
        let a = try Version.Semantic("1.0.0+a")
        let b = try Version.Semantic("1.0.0+b")
        #expect(a == b)
    }

    @Test
    func `Prerelease identifiers participate in equality`() throws(Version.Semantic.Error) {
        let a = try Version.Semantic("1.0.0-alpha")
        let b = try Version.Semantic("1.0.0-beta")
        #expect(a != b)
    }

    @Test
    func `Build metadata is excluded from hash (SemVer §10)`() throws(Version.Semantic.Error) {
        let a = try Version.Semantic("1.0.0+a")
        let b = try Version.Semantic("1.0.0+b")
        #expect(a.hashValue == b.hashValue)
    }
}

// MARK: - Precedence

extension VersionSemanticTests.Precedence {
    @Test
    func `Major version dominates ordering`() throws(Version.Semantic.Error) {
        let a = try Version.Semantic("1.99.99")
        let b = try Version.Semantic("2.0.0")
        #expect(a < b)
    }

    @Test
    func `Prerelease has lower precedence than release (SemVer §11.3)`() throws(Version.Semantic.Error) {
        let pre = try Version.Semantic("1.0.0-alpha")
        let rel = try Version.Semantic("1.0.0")
        #expect(pre < rel)
    }

    @Test
    func `Numeric prerelease has lower precedence than alphanumeric (SemVer §11.4)`() throws(Version.Semantic.Error) {
        let num = try Version.Semantic("1.0.0-1")
        let alpha = try Version.Semantic("1.0.0-alpha")
        #expect(num < alpha)
    }

    @Test
    func `Shorter prerelease wins on common prefix (SemVer §11.4)`() throws(Version.Semantic.Error) {
        let short = try Version.Semantic("1.0.0-alpha")
        let long = try Version.Semantic("1.0.0-alpha.1")
        #expect(short < long)
    }

    @Test
    func `Numeric prerelease compares numerically not lexically`() throws(Version.Semantic.Error) {
        let v9 = try Version.Semantic("1.0.0-9")
        let v10 = try Version.Semantic("1.0.0-10")
        #expect(v9 < v10)
    }

    @Test
    func `SemVer 2.0.0 spec precedence example`() throws(Version.Semantic.Error) {
        // Per semver.org §11 example: 1.0.0-alpha < 1.0.0-alpha.1
        //   < 1.0.0-alpha.beta < 1.0.0-beta < 1.0.0-beta.2
        //   < 1.0.0-beta.11 < 1.0.0-rc.1 < 1.0.0
        let versions = try [
            "1.0.0-alpha",
            "1.0.0-alpha.1",
            "1.0.0-alpha.beta",
            "1.0.0-beta",
            "1.0.0-beta.2",
            "1.0.0-beta.11",
            "1.0.0-rc.1",
            "1.0.0",
        ].map(Version.Semantic.init(_:))
        for index in versions.indices.dropLast() {
            #expect(versions[index] < versions[index + 1])
        }
    }
}

// MARK: - Description

extension VersionSemanticTests.Description {
    @Test
    func `Bare version round-trips`() throws(Version.Semantic.Error) {
        let v = try Version.Semantic("1.2.3")
        #expect(v.description == "1.2.3")
    }

    @Test
    func `Prerelease round-trips`() throws(Version.Semantic.Error) {
        let v = try Version.Semantic("1.0.0-alpha.1")
        #expect(v.description == "1.0.0-alpha.1")
    }

    @Test
    func `Build metadata round-trips`() throws(Version.Semantic.Error) {
        let v = try Version.Semantic("1.0.0+sha.abc")
        #expect(v.description == "1.0.0+sha.abc")
    }

    @Test
    func `Full round-trips`() throws(Version.Semantic.Error) {
        let v = try Version.Semantic("1.2.3-rc.1+build.456")
        #expect(v.description == "1.2.3-rc.1+build.456")
    }
}

// MARK: - Error cases

extension VersionSemanticTests.ErrorCases {
    @Test
    func `Two-component core rejected`() {
        #expect(throws: Version.Semantic.Error.self) {
            try Version.Semantic("1.2")
        }
    }

    @Test
    func `Four-component core rejected`() {
        #expect(throws: Version.Semantic.Error.self) {
            try Version.Semantic("1.2.3.4")
        }
    }

    @Test
    func `Leading zero in MAJOR rejected`() {
        #expect(throws: Version.Semantic.Error.self) {
            try Version.Semantic("01.0.0")
        }
    }

    @Test
    func `Non-numeric MAJOR rejected`() {
        #expect(throws: Version.Semantic.Error.self) {
            try Version.Semantic("a.0.0")
        }
    }

    @Test
    func `Empty prerelease identifier rejected`() {
        #expect(throws: Version.Semantic.Error.self) {
            try Version.Semantic("1.0.0-")
        }
    }

    @Test
    func `Leading zero in numeric prerelease rejected`() {
        #expect(throws: Version.Semantic.Error.self) {
            try Version.Semantic("1.0.0-01")
        }
    }

    @Test
    func `Non-ASCII rejected`() {
        #expect(throws: Version.Semantic.Error.self) {
            try Version.Semantic("1.0.0-α")
        }
    }

    @Test
    func `Empty build metadata identifier rejected`() {
        #expect(throws: Version.Semantic.Error.self) {
            try Version.Semantic("1.0.0+")
        }
    }
}
