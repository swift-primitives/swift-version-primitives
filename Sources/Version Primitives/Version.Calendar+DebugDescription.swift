internal import Time_Primitives

extension Version.Calendar: Swift.CustomDebugStringConvertible {

    public var debugDescription: Swift.String {
        switch self {
        case .yearOnly(let year, let modifier):
            return ".yearOnly(year: " + Self.format(year.rawValue)
                + ", modifier: " + Self.format(modifier) + ")"

        case .yearMonth(let year, let month, let modifier):
            return ".yearMonth(year: " + Self.format(year.rawValue)
                + ", month: " + Self.format(month.rawValue)
                + ", modifier: " + Self.format(modifier) + ")"

        case .full(let year, let month, let micro, let modifier):
            return ".full(year: " + Self.format(year.rawValue)
                + ", month: " + Self.format(month.rawValue)
                + ", micro: " + Self.format(Swift.Int(micro.underlying))
                + ", modifier: " + Self.format(modifier) + ")"
        }
    }

    @usableFromInline
    static func format(_ value: Swift.Int) -> Swift.String {
        Swift.String(value)
    }

    @usableFromInline
    static func format(_ modifier: Swift.String?) -> Swift.String {
        switch modifier {
        case .none: return "nil"
        case .some(let value): return "\"" + value + "\""
        }
    }
}
