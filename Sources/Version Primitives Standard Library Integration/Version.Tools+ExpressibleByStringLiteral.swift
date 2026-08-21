public import Version_Primitives

extension Version.Tools: ExpressibleByStringLiteral {

    @inlinable
    public init(stringLiteral value: Swift.String) {
        do {
            self = try Version.Tools(parsing: value)
        } catch {
            fatalError("Version.Tools literal failed to parse: \(value): \(error)")
        }
    }
}
