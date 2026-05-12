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

// Re-export ecosystem modules referenced by Version Primitives' public
// surface so consumers can use the type ergonomically:
//
// - `Tagged_Primitives` — `Tagged<...>` underlies the per-component
//   value typealiases (`Major.Value`, `Minor.Value`, `Patch.Value`).
// - `Tagged_Primitives_Standard_Library_Integration` —
//   `ExpressibleByIntegerLiteral` conformance for the Tagged components
//   so call sites can keep writing `Version.Semantic(major: 1, ...)`.
// - `Carrier_Primitives` — `Carrier.\`Protocol\`` conformance on
//   `Version.Semantic` (trivial self-carrier) participates in
//   Carrier-bound generic code without an explicit import at the use
//   site.

@_exported public import Carrier_Primitives
@_exported public import Tagged_Primitives
@_exported public import Tagged_Primitives_Standard_Library_Integration
