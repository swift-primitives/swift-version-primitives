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

public import Carrier_Primitives

extension Version.Semantic: Carrier.`Protocol` {
    /// Trivial self-carrier — `Version.Semantic` IS its own `Underlying`.
    ///
    /// The conformance lets `Version.Semantic` participate in
    /// `Carrier.\`Protocol\``-bound generic code without forcing
    /// consumers to wrap or unwrap. Semantically the version is its
    /// own canonical underlying representation; there is no separate
    /// String-or-other carrier value to expose.
    ///
    /// Consumers needing the canonical SemVer string form use
    /// ``Version/Semantic/description`` (CustomStringConvertible)
    /// or ``Version/Semantic/init(_:)`` (LosslessStringConvertible).
    public typealias Underlying = Version.Semantic
}
