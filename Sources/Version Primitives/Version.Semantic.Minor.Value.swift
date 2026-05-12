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

public import Tagged_Primitives

extension Version.Semantic.Minor {
    /// Typed MINOR component value: `Tagged<Minor, Swift.UInt>`.
    ///
    /// Construction accepts integer literals
    /// (`ExpressibleByIntegerLiteral` flows through `Underlying`),
    /// so `Version.Semantic(major: 1, minor: 0, patch: 0)` continues
    /// to read naturally despite the typed wrapper.
    public typealias Value = Tagged<Version.Semantic.Minor, Swift.UInt>
}
