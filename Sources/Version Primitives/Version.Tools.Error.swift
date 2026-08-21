public import Text_Primitives

extension Version.Tools {

    public enum Error: Swift.Error, Swift.Sendable, Swift.Hashable {

        case nonASCIICharacters(input: Swift.String, range: Text.Range)

        case invalidToolsVersionIdentifierCount(input: Swift.String, range: Text.Range)

        case invalidToolsVersionIdentifier(
            input: Swift.String,
            identifier: Swift.String,
            range: Text.Range
        )
    }
}

extension Version.Tools.Error {

    @inlinable
    public var range: Text.Range {
        switch self {
        case .nonASCIICharacters(_, let range): return range
        case .invalidToolsVersionIdentifierCount(_, let range): return range
        case .invalidToolsVersionIdentifier(_, _, let range): return range
        }
    }

    @inlinable
    public var input: Swift.String {
        switch self {
        case .nonASCIICharacters(let input, _): return input
        case .invalidToolsVersionIdentifierCount(let input, _): return input
        case .invalidToolsVersionIdentifier(let input, _, _): return input
        }
    }
}
