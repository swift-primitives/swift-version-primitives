extension Version.Range {

    @inlinable
    public init(_ range: Swift.Range<Underlying>) {
        self.init(
            lowerBound: .inclusive(range.lowerBound),
            upperBound: .exclusive(range.upperBound)
        )
    }
}
