extension Version {

    public struct Range<Underlying: Swift.Hashable & Swift.Comparable>: Swift.Hashable {

        public let lowerBound: Bound

        public let upperBound: Bound

        @inlinable
        public init(lowerBound: Bound, upperBound: Bound) {
            self.lowerBound = lowerBound
            self.upperBound = upperBound
        }

        @inlinable
        public static var all: Self {
            Self(lowerBound: .unbounded, upperBound: .unbounded)
        }

        @inlinable
        public static func exact(_ version: Underlying) -> Self {
            Self(lowerBound: .inclusive(version), upperBound: .inclusive(version))
        }

        @inlinable
        public func contains(_ version: Underlying) -> Swift.Bool {
            switch self.lowerBound {
            case .unbounded: break
            case .inclusive(let lower): if version < lower { return false }
            case .exclusive(let lower): if version <= lower { return false }
            }
            switch self.upperBound {
            case .unbounded: break
            case .inclusive(let upper): if version > upper { return false }
            case .exclusive(let upper): if version >= upper { return false }
            }
            return true
        }
    }
}

extension Version.Range: Swift.Sendable where Underlying: Swift.Sendable {}
