extension Version.Range {

    public enum Bound: Swift.Hashable {

        case unbounded

        case inclusive(Underlying)

        case exclusive(Underlying)
    }
}

extension Version.Range.Bound: Swift.Sendable where Underlying: Swift.Sendable {}
