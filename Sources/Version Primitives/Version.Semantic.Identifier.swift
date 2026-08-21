extension Version.Semantic {

    public enum Identifier: Swift.Sendable, Swift.Hashable, Swift.Comparable {

        case numeric(Swift.UInt)

        case alphanumeric(Swift.String)
    }
}

extension Version.Semantic.Identifier {

    public static func < (lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs) {
        case (.numeric(let l), .numeric(let r)): return l < r
        case (.numeric, .alphanumeric): return true
        case (.alphanumeric, .numeric): return false
        case (.alphanumeric(let l), .alphanumeric(let r)): return l < r
        }
    }
}
