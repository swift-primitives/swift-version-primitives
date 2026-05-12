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

extension Version.Calendar {
    /// Phantom tag for the MICRO component of a CalVer.
    ///
    /// "Micro" is the third-position component (e.g., the `13` in
    /// `2026.05.13`). It may be a day, sequence number, or other
    /// scheme-specific value per calver.org.
    public enum Micro: Swift.Sendable {}
}
