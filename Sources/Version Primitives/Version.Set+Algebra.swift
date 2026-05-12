// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-version-primitives open source project
//
// Copyright (c) 2026 Coen ten Thije Boonkkamp and the swift-version-primitives project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// ===----------------------------------------------------------------------===//

extension Version.Set {
    /// Whether this set contains zero versions.
    ///
    /// Intensional check — does not enumerate the set; computes
    /// emptiness from the case structure alone.
    @inlinable
    public var isEmpty: Swift.Bool {
        switch self {
        case .empty:
            return true

        case .any, .exact:
            return false

        case .range(let interval):
            return interval.isEmpty

        case .union(let members):
            for member in members where !member.isEmpty {
                return false
            }
            return true
        }
    }

    /// A canonical form of this set with no redundant structure.
    ///
    /// Normalization rules:
    /// - `.union([])` → `.empty`
    /// - `.union([s])` → `s.normalized`
    /// - Nested `.union(.union(...))` flattens
    /// - Empty members are dropped from unions
    /// - `.any` inside a union collapses the union to `.any`
    /// - `.range` with an empty interval collapses to `.empty`
    ///
    /// Two semantically-equal sets compare equal after
    /// normalization. Useful before `Hashable`-based deduplication.
    @inlinable
    public func normalized() -> Self {
        switch self {
        case .empty, .any, .exact:
            return self

        case .range(let interval):
            return interval.isEmpty ? .empty : self

        case .union(let members):
            var flattened: [Self] = []
            for member in members {
                let canonical = member.normalized()
                switch canonical {
                case .empty:
                    continue

                case .any:
                    return .any

                case .union(let nested):
                    flattened.append(contentsOf: nested)

                default:
                    flattened.append(canonical)
                }
            }
            switch flattened.count {
            case 0: return .empty
            case 1: return flattened[0]
            default: return .union(flattened)
            }
        }
    }

    /// The union of this set with `other`.
    ///
    /// Returns the disjunctive combination — versions in either
    /// input — normalized to canonical form. Equivalent to
    /// `.union([self, other]).normalized()` but avoids the
    /// intermediate value.
    @inlinable
    public func union(_ other: Self) -> Self {
        Self.union([self, other]).normalized()
    }

    /// The intersection of this set with `other`.
    ///
    /// Returns the conjunctive combination — versions in both
    /// inputs — in canonical form.
    @inlinable
    public func intersection(_ other: Self) -> Self {
        switch (self, other) {
        case (.empty, _), (_, .empty):
            return .empty

        case (.any, let value), (let value, .any):
            return value

        case (.exact(let lhs), .exact(let rhs)):
            return lhs == rhs ? .exact(lhs) : .empty

        case (.exact(let value), _):
            return other.contains(value) ? .exact(value) : .empty

        case (_, .exact(let value)):
            return self.contains(value) ? .exact(value) : .empty

        case (.range(let lhs), .range(let rhs)):
            let intersected = lhs.intersection(rhs)
            return intersected.isEmpty ? .empty : .range(intersected)

        case (.union(let members), _):
            return Self.union(members.map { $0.intersection(other) }).normalized()

        case (_, .union(let members)):
            return Self.union(members.map { self.intersection($0) }).normalized()
        }
    }
}
