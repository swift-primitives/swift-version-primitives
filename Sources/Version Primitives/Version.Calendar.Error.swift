public import Text_Primitives

extension Version.Calendar {

    public enum Error: Swift.Error, Swift.Sendable, Swift.Hashable {

        case nonASCIICharacters(input: Swift.String, range: Text.Range)

        case invalidCalendarIdentifier(
            input: Swift.String,
            identifier: Swift.String,
            range: Text.Range
        )

        case invalidMonth(input: Swift.String, value: Swift.Int, range: Text.Range)

        case emptyModifier(input: Swift.String, range: Text.Range)

        case invalidModifierCharacters(
            input: Swift.String,
            modifier: Swift.String,
            range: Text.Range
        )
    }
}

extension Version.Calendar.Error {

    @inlinable
    public var range: Text.Range {
        switch self {
        case .nonASCIICharacters(_, let range): return range
        case .invalidCalendarIdentifier(_, _, let range): return range
        case .invalidMonth(_, _, let range): return range
        case .emptyModifier(_, let range): return range
        case .invalidModifierCharacters(_, _, let range): return range
        }
    }

    @inlinable
    public var input: Swift.String {
        switch self {
        case .nonASCIICharacters(let input, _): return input
        case .invalidCalendarIdentifier(let input, _, _): return input
        case .invalidMonth(let input, _, _): return input
        case .emptyModifier(let input, _): return input
        case .invalidModifierCharacters(let input, _, _): return input
        }
    }
}
