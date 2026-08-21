extension Version.Semantic.Phase: Swift.CustomStringConvertible {

    @inlinable
    public var description: Swift.String {
        switch self {
        case .initial: return "initial"
        case .stable: return "stable"
        }
    }
}

extension Version.Semantic.Phase: Swift.CustomDebugStringConvertible {

    @inlinable
    public var debugDescription: Swift.String {
        switch self {
        case .initial: return ".initial"
        case .stable: return ".stable"
        }
    }
}
