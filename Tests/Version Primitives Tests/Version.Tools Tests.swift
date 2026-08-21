import Testing
import Version_Primitives

extension Version.Tools {
    @Suite struct Test {
        @Suite struct Construction {}
        @Suite struct Comparison {}
        @Suite struct RoundTrip {}
        @Suite struct ErrorCases {}
    }
}

extension Version.Tools.Test.Construction {
    @Test
    func `Parses MAJOR.MINOR form`() throws(Version.Tools.Error) {
        let v = try Version.Tools(parsing: "6.3")
        #expect(v.major.underlying == 6)
        #expect(v.minor.underlying == 3)
        #expect(v.patch == nil)
    }

    @Test
    func `Parses MAJOR.MINOR.PATCH form`() throws(Version.Tools.Error) {
        let v = try Version.Tools(parsing: "6.3.1")
        #expect(v.major.underlying == 6)
        #expect(v.minor.underlying == 3)
        #expect(v.patch?.underlying == 1)
    }

    @Test
    func `Component init accepts integer literals`() {
        let v = Version.Tools(major: 6, minor: 3, patch: 1)
        #expect(v.major.underlying == 6)
        #expect(v.minor.underlying == 3)
        #expect(v.patch?.underlying == 1)
    }
}

extension Version.Tools.Test.Comparison {
    @Test
    func `Major dominates`() throws(Version.Tools.Error) {
        let a = try Version.Tools(parsing: "5.99")
        let b = try Version.Tools(parsing: "6.0")
        #expect(a < b)
    }

    @Test
    func `Absent patch behaves as zero`() throws(Version.Tools.Error) {
        let bare = try Version.Tools(parsing: "6.3")
        let zeroed = try Version.Tools(parsing: "6.3.0")
        #expect(!(bare < zeroed))
        #expect(!(zeroed < bare))

        #expect(bare != zeroed)
    }

    @Test
    func `Patch participates when both have it`() throws(Version.Tools.Error) {
        let a = try Version.Tools(parsing: "6.3.0")
        let b = try Version.Tools(parsing: "6.3.1")
        #expect(a < b)
    }
}

extension Version.Tools.Test.RoundTrip {
    @Test
    func `Short form round-trips without adding 0 patch`() throws(Version.Tools.Error) {
        let v = try Version.Tools(parsing: "6.3")
        #expect(v.description == "6.3")
    }

    @Test
    func `Full form round-trips`() throws(Version.Tools.Error) {
        let v = try Version.Tools(parsing: "6.3.1")
        #expect(v.description == "6.3.1")
    }
}

extension Version.Tools.Test.ErrorCases {
    @Test
    func `Single-component rejected`() {
        #expect(throws: Version.Tools.Error.self) {
            try Version.Tools(parsing: "6")
        }
    }

    @Test
    func `Four-component rejected`() {
        #expect(throws: Version.Tools.Error.self) {
            try Version.Tools(parsing: "6.3.1.0")
        }
    }

    @Test
    func `Leading zero in MAJOR rejected`() {
        #expect(throws: Version.Tools.Error.self) {
            try Version.Tools(parsing: "06.3")
        }
    }

    @Test
    func `Pre-release rejected`() {
        #expect(throws: Version.Tools.Error.self) {
            try Version.Tools(parsing: "6.3-alpha")
        }
    }

    @Test
    func `Empty rejected`() {
        #expect(throws: Version.Tools.Error.self) {
            try Version.Tools(parsing: "")
        }
    }
}
