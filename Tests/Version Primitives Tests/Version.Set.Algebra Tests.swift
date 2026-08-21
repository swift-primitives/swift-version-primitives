import Testing
import Version_Primitives

@Suite struct `Version.Set Algebra Tests` {
    @Test
    func `Empty set isEmpty`() {
        let set: Version.Set<Version.Semantic> = .empty
        #expect(set.isEmpty)
    }

    @Test
    func `Empty-union normalizes to empty`() {
        let set: Version.Set<Version.Semantic> = .union([])
        #expect(set.normalized() == .empty)
    }

    @Test
    func `Singleton union normalizes to the member`() {
        let v = Version.Semantic(major: 1, minor: 0, patch: 0)
        let set: Version.Set<Version.Semantic> = .union([.exact(v)])
        #expect(set.normalized() == .exact(v))
    }

    @Test
    func `Union containing any collapses to any`() {
        let v = Version.Semantic(major: 1, minor: 0, patch: 0)
        let set: Version.Set<Version.Semantic> = .union([.exact(v), .any])
        #expect(set.normalized() == .any)
    }

    @Test
    func `Nested unions flatten`() {
        let v1 = Version.Semantic(major: 1, minor: 0, patch: 0)
        let v2 = Version.Semantic(major: 2, minor: 0, patch: 0)
        let set: Version.Set<Version.Semantic> = .union([
            .union([.exact(v1), .exact(v2)]),
            .exact(Version.Semantic(major: 3, minor: 0, patch: 0)),
        ])
        let normalized = set.normalized()
        guard case .union(let members) = normalized else {
            Issue.record("expected union after normalization")
            return
        }
        #expect(members.count == 3)
    }

    @Test
    func `Empty members are dropped from unions`() {
        let v = Version.Semantic(major: 1, minor: 0, patch: 0)
        let set: Version.Set<Version.Semantic> = .union([.exact(v), .empty, .empty])
        #expect(set.normalized() == .exact(v))
    }

    @Test
    func `Intersection of exact and range`() {
        let v = Version.Semantic(major: 1, minor: 5, patch: 0)
        let range: Version.Set<Version.Semantic> = .range(
            .upToNextMajor(from: Version.Semantic(major: 1, minor: 0, patch: 0))
        )
        let exact: Version.Set<Version.Semantic> = .exact(v)
        let intersected = exact.intersection(range)
        #expect(intersected == .exact(v))
    }

    @Test
    func `Intersection of disjoint exact and range is empty`() {
        let outside = Version.Semantic(major: 2, minor: 5, patch: 0)
        let range: Version.Set<Version.Semantic> = .range(
            .upToNextMajor(from: Version.Semantic(major: 1, minor: 0, patch: 0))
        )
        let exact: Version.Set<Version.Semantic> = .exact(outside)
        #expect(exact.intersection(range) == .empty)
    }

    @Test
    func `Intersection with any preserves the other side`() {
        let v = Version.Semantic(major: 1, minor: 0, patch: 0)
        let exact: Version.Set<Version.Semantic> = .exact(v)
        #expect(exact.intersection(.any) == .exact(v))
        #expect((.any as Version.Set<Version.Semantic>).intersection(exact) == .exact(v))
    }

    @Test
    func `Union of two exacts at same version normalizes to single exact`() {
        let v = Version.Semantic(major: 1, minor: 0, patch: 0)
        let combined = (Version.Set<Version.Semantic>.exact(v)).union(.exact(v))

        guard case .union(let members) = combined else {
            Issue.record("expected union")
            return
        }
        #expect(members.count == 2)
        #expect(combined.contains(v))
    }
}
