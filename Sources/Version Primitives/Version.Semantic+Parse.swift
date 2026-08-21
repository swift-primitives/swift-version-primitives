extension Version.Semantic {

    @inlinable

    public init(_ string: Swift.String) throws(Version.Semantic.Error) {
        try self.init(parsing: string)
    }
}
