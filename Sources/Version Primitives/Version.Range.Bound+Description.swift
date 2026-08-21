extension Version.Range.Bound: Swift.CustomStringConvertible
where Underlying: Swift.CustomStringConvertible {

    public var description: Swift.String {
        switch self {
        case .unbounded:
            return "unbounded"

        case .inclusive(let value):
            return "inclusive(" + value.description + ")"

        case .exclusive(let value):
            return "exclusive(" + value.description + ")"
        }
    }
}
