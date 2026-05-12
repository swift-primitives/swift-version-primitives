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

extension Version.Semantic.Phase: Swift.CustomStringConvertible {
    /// A short textual name for this phase.
    ///
    /// | Case | Description |
    /// |---|---|
    /// | ``initial`` | `"initial"` |
    /// | ``stable`` | `"stable"` |
    @inlinable
    public var description: Swift.String {
        switch self {
        case .initial: return "initial"
        case .stable: return "stable"
        }
    }
}

extension Version.Semantic.Phase: Swift.CustomDebugStringConvertible {
    /// A structural representation preserving the case form with a
    /// leading dot.
    @inlinable
    public var debugDescription: Swift.String {
        switch self {
        case .initial: return ".initial"
        case .stable: return ".stable"
        }
    }
}
