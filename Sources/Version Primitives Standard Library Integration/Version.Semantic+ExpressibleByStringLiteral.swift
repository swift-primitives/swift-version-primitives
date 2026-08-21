public import Version_Primitives

extension Version.Semantic: ExpressibleByStringLiteral {

    @inlinable
    public init(stringLiteral value: Swift.String) {
        do {
            self = try Version.Semantic(value)
        } catch {
            fatalError("Version.Semantic literal failed to parse: \(value): \(error)")
        }
    }
}
