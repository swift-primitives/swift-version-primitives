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

extension Version.Tools.Minor {
    /// Typed MINOR component for an SE-0152 tools version.
    public typealias Value = Tagged<Version.Tools.Minor, Swift.UInt>
}
