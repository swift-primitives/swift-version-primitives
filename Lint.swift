// swift-linter-tools-version: 0.1
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

// Shape-γ unified consumer manifest per
// swift-institute/Research/2026-05-12-swift-linter-unified-consumer-manifest.md.
//
// swift-version-primitives is a Carrier consumer (Version.Semantic is a
// trivial self-carrier — its own Underlying) rather than a brand-owner,
// so it activates the full primitives bundle — no brand-owner carve-outs
// apply.

import Linter
import Linter_Primitives_Rules

Lint.run(dependencies: [
    .package(
        path: "../swift-primitives-linter-rules",
        products: ["Linter Primitives Rules"]
    ),
]) {
    Lint.Rule.Bundle.primitives
}
