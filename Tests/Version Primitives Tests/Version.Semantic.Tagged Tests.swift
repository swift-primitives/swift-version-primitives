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

import Testing
import Version_Primitives

extension Version.Semantic.Test {
    @Suite struct Tagged {
        @Test
        func `Integer literal flows through to tagged component`() {
            let major: Version.Semantic.Major.Value = 1
            let minor: Version.Semantic.Minor.Value = 2
            let patch: Version.Semantic.Patch.Value = 3
            #expect(major.underlying == 1)
            #expect(minor.underlying == 2)
            #expect(patch.underlying == 3)
        }

        @Test
        func `Component init accepts integer literals`() {
            let v = Version.Semantic(major: 1, minor: 2, patch: 3)
            #expect(v.major.underlying == 1)
            #expect(v.minor.underlying == 2)
            #expect(v.patch.underlying == 3)
        }

        @Test
        func `Tag namespaces are type-distinct`() {
            // Compile-time witness: each component has its own type.
            // This test exists so the assertion is exercised at runtime
            // and so a regression that collapsed the tag distinction
            // would surface via a metatype-equality failure.
            #expect(Version.Semantic.Major.Value.self != Version.Semantic.Minor.Value.self)
            #expect(Version.Semantic.Minor.Value.self != Version.Semantic.Patch.Value.self)
            #expect(Version.Semantic.Major.Value.self != Version.Semantic.Patch.Value.self)
        }
    }
}
