extension Version.Semantic {

    public enum Phase: Swift.Sendable, Swift.Hashable {

        case initial

        case stable
    }

    @inlinable
    public var phase: Phase {
        self.major.underlying == 0 ? .initial : .stable
    }
}
