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

public import Version_Primitives

extension Version.Semantic: ExpressibleByStringLiteral {
    /// Constructs a `Version.Semantic` from a string literal.
    ///
    /// Parses the literal eagerly via `Version.Semantic(_:)`. A
    /// malformed literal traps with `fatalError` — literals authored at
    /// the call site are reviewable surface text, so a parse failure
    /// indicates an authoring-time defect that surfaces at build-load
    /// time rather than at the first comparison call. Use the throwing
    /// `init(_:)` directly for versions whose validity cannot be
    /// guaranteed at compile time.
    @inlinable
    public init(stringLiteral value: Swift.String) {
        do {
            self = try Version.Semantic(value)
        } catch {
            fatalError("Version.Semantic literal failed to parse: \(value): \(error)")
        }
    }
}
