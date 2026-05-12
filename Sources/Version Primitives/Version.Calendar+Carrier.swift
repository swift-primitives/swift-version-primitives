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

extension Version.Calendar: Carrier.`Protocol` {
    /// Trivial self-carrier — `Version.Calendar` IS its own
    /// `Underlying`, matching the pattern of `Version.Semantic` and
    /// `Version.Tools`.
    public typealias Underlying = Version.Calendar
}
