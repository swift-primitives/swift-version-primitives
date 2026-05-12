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
    /// Phantom tag for the PATCH version component per SemVer 2.0.0 §2.
    ///
    /// Pairs with ``Version/Semantic/Patch/Value`` to give PATCH a
    /// distinct type from MAJOR and MINOR at compile time — preventing
    /// positional swaps at construction sites.
    public enum Patch: Swift.Sendable {}
}
