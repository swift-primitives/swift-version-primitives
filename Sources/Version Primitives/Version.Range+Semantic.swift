extension Version.Range where Underlying == Version.Semantic {

    @inlinable
    public static func upToNextMajor(from version: Version.Semantic) -> Self {
        let nextMajor = Version.Semantic(
            major: .init(version.major.underlying + 1),
            minor: 0,
            patch: 0
        )
        return Self(lowerBound: .inclusive(version), upperBound: .exclusive(nextMajor))
    }

    @inlinable
    public static func upToNextMinor(from version: Version.Semantic) -> Self {
        let nextMinor = Version.Semantic(
            major: .init(version.major.underlying),
            minor: .init(version.minor.underlying + 1),
            patch: 0
        )
        return Self(lowerBound: .inclusive(version), upperBound: .exclusive(nextMinor))
    }
}
