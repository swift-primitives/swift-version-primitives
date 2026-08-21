extension Version {

    public indirect enum Set<Underlying: Swift.Hashable & Swift.Comparable>: Swift.Hashable {

        case empty

        case any

        case exact(Underlying)

        case range(Version.Range<Underlying>)

        case union([Version.Set<Underlying>])
    }
}

extension Version.Set {

    @inlinable
    public func contains(_ version: Underlying) -> Swift.Bool {
        switch self {
        case .empty:
            return false

        case .any:
            return true

        case .exact(let target):
            return version == target

        case .range(let interval):
            return interval.contains(version)

        case .union(let members):
            for member in members where member.contains(version) {
                return true
            }
            return false
        }
    }
}

extension Version.Set: Swift.Sendable where Underlying: Swift.Sendable {}
