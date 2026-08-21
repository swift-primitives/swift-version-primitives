extension Version.Set: Swift.CustomStringConvertible
where Underlying: Swift.CustomStringConvertible {

    public var description: Swift.String {
        switch self {
        case .empty:
            return "∅"

        case .any:
            return "*"

        case .exact(let value):
            return "{" + value.description + "}"

        case .range(let interval):
            return interval.description

        case .union(let members):
            switch members.count {
            case 0:
                return "∅"

            case 1:
                return members[0].description

            default:
                return "(" + members.map(\.description).joined(separator: " ∪ ") + ")"
            }
        }
    }
}

extension Version.Set: Swift.CustomDebugStringConvertible
where Underlying: Swift.CustomStringConvertible {

    public var debugDescription: Swift.String {
        switch self {
        case .empty:
            return ".empty"

        case .any:
            return ".any"

        case .exact(let value):
            return ".exact(" + value.description + ")"

        case .range(let interval):
            return ".range(" + interval.description + ")"

        case .union(let members):
            let inner = members.map(\.debugDescription).joined(separator: ", ")
            return ".union([" + inner + "])"
        }
    }
}
