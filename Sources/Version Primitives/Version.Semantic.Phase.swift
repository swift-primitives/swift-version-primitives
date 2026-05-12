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
    /// The development phase a SemVer 2.0.0 version sits in.
    ///
    /// Spec basis:
    ///
    /// - SemVer 2.0.0 §4: "Major version zero (0.y.z) is for
    ///   initial development. Anything MAY change at any time. The
    ///   public API SHOULD NOT be considered stable."
    /// - SemVer 2.0.0 §5: "Version 1.0.0 defines the public API."
    ///
    /// Two cases capture this binary distinction. Avoids the
    /// compound `isInitialDevelopment` accessor name (forbidden by
    /// `[API-NAME-002]`).
    ///
    /// ```swift
    /// switch version.phase {
    /// case .initial: // 0.x.y — APIs unstable
    /// case .stable:  // 1.x.y+ — public API committed
    /// }
    /// ```
    public enum Phase: Swift.Sendable, Swift.Hashable {
        /// Initial-development phase (MAJOR == 0) per SemVer §4.
        case initial

        /// Stable-public-API phase (MAJOR >= 1) per SemVer §5.
        case stable
    }

    /// The development phase of this version per SemVer 2.0.0 §4/§5.
    @inlinable
    public var phase: Phase {
        self.major.underlying == 0 ? .initial : .stable
    }
}
