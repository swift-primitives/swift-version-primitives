extension Version.Range: Swift.CustomStringConvertible
where Underlying: Swift.CustomStringConvertible {

    public var description: Swift.String {
        let left: Swift.String
        switch self.lowerBound {
        case .unbounded:
            left = "(-∞"

        case .inclusive(let value):
            left = "[" + value.description

        case .exclusive(let value):
            left = "(" + value.description
        }
        let right: Swift.String
        switch self.upperBound {
        case .unbounded:
            right = "+∞)"

        case .inclusive(let value):
            right = value.description + "]"

        case .exclusive(let value):
            right = value.description + ")"
        }
        return left + ", " + right
    }
}
