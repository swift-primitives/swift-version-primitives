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
    /// A pre-release identifier per SemVer 2.0.0 §9.
    ///
    /// Pre-release identifiers are dot-separated tokens after the
    /// hyphen in a version string (e.g., `1.0.0-alpha.1` has two
    /// identifiers: `alpha` (alphanumeric) and `1` (numeric)). The
    /// precedence rule at §11.4 distinguishes numeric identifiers
    /// (compared numerically) from alphanumeric identifiers
    /// (compared lexicographically); the typed representation
    /// preserves the distinction.
    public enum Identifier: Swift.Sendable, Swift.Hashable, Swift.Comparable {
        /// A numeric identifier — non-negative integer with no
        /// leading zeros per SemVer 2.0.0 §9.
        case numeric(Swift.UInt)

        /// An alphanumeric identifier — at least one non-digit
        /// character per SemVer 2.0.0 §9.
        case alphanumeric(Swift.String)
    }
}

extension Version.Semantic.Identifier {
    /// SemVer 2.0.0 §11.4 precedence between pre-release identifiers.
    ///
    /// - Numeric identifiers always have lower precedence than
    ///   alphanumeric identifiers.
    /// - Identifiers consisting of only digits are compared
    ///   numerically.
    /// - Identifiers with letters or hyphens are compared
    ///   lexically in ASCII sort order.
    public static func < (lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs) {
        case (.numeric(let l), .numeric(let r)): return l < r
        case (.numeric, .alphanumeric): return true
        case (.alphanumeric, .numeric): return false
        case (.alphanumeric(let l), .alphanumeric(let r)): return l < r
        }
    }
}
