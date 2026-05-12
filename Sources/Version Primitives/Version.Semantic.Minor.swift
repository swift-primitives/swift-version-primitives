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
    /// Phantom tag for the MINOR version component per SemVer 2.0.0 §2.
    ///
    /// Pairs with ``Version/Semantic/Minor/Value`` to give MINOR a
    /// distinct type from MAJOR and PATCH at compile time — preventing
    /// positional swaps at construction sites.
    public enum Minor: Swift.Sendable {}
}
