extension Version.Semantic {

    public struct Bumped: Swift.Sendable {
        @usableFromInline
        let base: Version.Semantic

        @inlinable
        package init(_ base: Version.Semantic) {
            self.base = base
        }
    }

    @inlinable
    public var bumped: Bumped {
        Bumped(self)
    }
}

extension Version.Semantic.Bumped {

    @inlinable
    public var major: Version.Semantic {
        Version.Semantic(
            major: .init(self.base.major.underlying + 1),
            minor: 0,
            patch: 0
        )
    }

    @inlinable
    public var minor: Version.Semantic {
        Version.Semantic(
            major: self.base.major,
            minor: .init(self.base.minor.underlying + 1),
            patch: 0
        )
    }

    @inlinable
    public var patch: Version.Semantic {
        Version.Semantic(
            major: self.base.major,
            minor: self.base.minor,
            patch: .init(self.base.patch.underlying + 1)
        )
    }
}
