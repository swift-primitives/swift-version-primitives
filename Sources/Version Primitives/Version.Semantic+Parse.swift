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

extension Version.Semantic {
    /// Bare-positional throwing init — the institute "throwing init
    /// indicates parsing" convention. The `try` keyword at the call
    /// site signals parsing semantics; no `parsing:` label needed:
    ///
    /// ```swift
    /// let v = try Version.Semantic("1.5.0")
    /// ```
    ///
    /// Equivalent to ``init(parsing:)`` — strict, asserts the entire
    /// string is consumed (non-ASCII detection + trailing-bytes
    /// check). Coexists with ``init(_:)-9rqx7`` (the failable
    /// `LosslessStringConvertible` shim) without ambiguity: Swift's
    /// overload resolution selects the throwing form when `try`
    /// is present at the call site and the failable form otherwise.
    @inlinable
    // swiftlint:disable:next prefer_self_in_static_references - reason: typed-throws clauses spell out the concrete error type per [API-ERR-001]; `throws(Self.Error)` would obscure the thrown type at the call site.
    public init(_ string: Swift.String) throws(Version.Semantic.Error) {
        try self.init(parsing: string)
    }
}
