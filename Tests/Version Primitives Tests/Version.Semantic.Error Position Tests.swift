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
import Text_Primitives
import Version_Primitives

extension Version.Semantic.Error {
    @Suite struct Test {
        @Test
        func `Leading zero in MAJOR reports the digit-run range`() {
            do {
                _ = try Version.Semantic("01.0.0")
                Issue.record("expected throw")
            } catch let error as Version.Semantic.Error {
                #expect(error.range.start.underlying.rawValue == 0)
                #expect(error.range.end.underlying.rawValue == 2)
            } catch {
                Issue.record("unexpected error: \(error)")
            }
        }

        @Test
        func `Two-component core reports range at end of input`() {
            do {
                _ = try Version.Semantic("1.2")
                Issue.record("expected throw")
            } catch let error as Version.Semantic.Error {
                #expect(error.range.start.underlying.rawValue == 3)
            } catch {
                Issue.record("unexpected error: \(error)")
            }
        }

        @Test
        func `Non-ASCII reports the offending byte position`() {
            // The Greek letter alpha (α) is 2 UTF-8 bytes starting at
            // byte offset 6 in "1.0.0-α".
            do {
                _ = try Version.Semantic("1.0.0-α")
                Issue.record("expected throw")
            } catch let error as Version.Semantic.Error {
                #expect(error.range.start.underlying.rawValue == 6)
                #expect(error.range.end.underlying.rawValue == 7)
            } catch {
                Issue.record("unexpected error: \(error)")
            }
        }

        @Test
        func `Trailing bytes report range after consumed prefix`() {
            do {
                _ = try Version.Semantic("1.2.3.4")
                Issue.record("expected throw")
            } catch let error as Version.Semantic.Error {
                // Parser consumes "1.2.3" (5 bytes). Trailing ".4"
                // begins at offset 5 and runs to offset 7.
                #expect(error.range.start.underlying.rawValue == 5)
                #expect(error.range.end.underlying.rawValue == 7)
            } catch {
                Issue.record("unexpected error: \(error)")
            }
        }

        @Test
        func `Empty pre-release reports the dash-following position`() {
            do {
                _ = try Version.Semantic("1.0.0-")
                Issue.record("expected throw")
            } catch let error as Version.Semantic.Error {
                // Pre-release segment starts after the '-' at offset 6.
                #expect(error.range.start.underlying.rawValue == 6)
            } catch {
                Issue.record("unexpected error: \(error)")
            }
        }
    }
}
