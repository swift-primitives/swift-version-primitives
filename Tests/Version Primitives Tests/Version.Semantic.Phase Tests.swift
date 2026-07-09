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

extension Version.Semantic.Phase {
    @Suite struct Test {
        @Test
        func `Zero major is initial`() {
            let v = Version.Semantic(major: 0, minor: 1, patch: 0)
            #expect(v.phase == .initial)
        }

        @Test
        func `One major is stable`() {
            let v = Version.Semantic(major: 1, minor: 0, patch: 0)
            #expect(v.phase == .stable)
        }

        @Test
        func `Pre-release zero-major stays initial`() throws(Version.Semantic.Error) {
            let v = try Version.Semantic("0.9.0-rc.1")
            #expect(v.phase == .initial)
        }

        @Test
        func `Major bump from zero crosses to stable`() {
            let initial = Version.Semantic(major: 0, minor: 99, patch: 99)
            #expect(initial.phase == .initial)
            #expect(initial.bumped.major.phase == .stable)
        }
    }
}
