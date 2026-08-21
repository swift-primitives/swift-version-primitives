public import Text_Primitives

extension Version.Semantic {

    public enum Error: Swift.Error, Swift.Sendable, Swift.Hashable {

        case nonASCIICharacters(input: Swift.String, range: Text.Range)

        case invalidVersionCoreIdentifierCount(
            input: Swift.String,
            found: Swift.Int,
            range: Text.Range
        )

        case invalidVersionCoreIdentifier(
            input: Swift.String,
            identifier: Swift.String,
            range: Text.Range
        )

        case emptyPreReleaseIdentifier(input: Swift.String, range: Text.Range)

        case invalidPreReleaseIdentifierCharacters(
            input: Swift.String,
            identifier: Swift.String,
            range: Text.Range
        )

        case leadingZeroInNumericPreReleaseIdentifier(
            input: Swift.String,
            identifier: Swift.String,
            range: Text.Range
        )

        case emptyBuildMetadataIdentifier(input: Swift.String, range: Text.Range)

        case invalidBuildMetadataIdentifierCharacters(
            input: Swift.String,
            identifier: Swift.String,
            range: Text.Range
        )
    }
}

extension Version.Semantic.Error {

    @inlinable
    public var range: Text.Range {
        switch self {
        case .nonASCIICharacters(_, let range): return range
        case .invalidVersionCoreIdentifierCount(_, _, let range): return range
        case .invalidVersionCoreIdentifier(_, _, let range): return range
        case .emptyPreReleaseIdentifier(_, let range): return range
        case .invalidPreReleaseIdentifierCharacters(_, _, let range): return range
        case .leadingZeroInNumericPreReleaseIdentifier(_, _, let range): return range
        case .emptyBuildMetadataIdentifier(_, let range): return range
        case .invalidBuildMetadataIdentifierCharacters(_, _, let range): return range
        }
    }

    @inlinable
    public var input: Swift.String {
        switch self {
        case .nonASCIICharacters(let input, _): return input
        case .invalidVersionCoreIdentifierCount(let input, _, _): return input
        case .invalidVersionCoreIdentifier(let input, _, _): return input
        case .emptyPreReleaseIdentifier(let input, _): return input
        case .invalidPreReleaseIdentifierCharacters(let input, _, _): return input
        case .leadingZeroInNumericPreReleaseIdentifier(let input, _, _): return input
        case .emptyBuildMetadataIdentifier(let input, _): return input
        case .invalidBuildMetadataIdentifierCharacters(let input, _, _): return input
        }
    }
}
