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
            } catch let error {
                #expect(error.range.start.underlying.rawValue == 0)
                #expect(error.range.end.underlying.rawValue == 2)
            }
        }

        @Test
        func `Two-component core reports range at end of input`() {
            do {
                _ = try Version.Semantic("1.2")
                Issue.record("expected throw")
            } catch let error {
                #expect(error.range.start.underlying.rawValue == 3)
            }
        }

        @Test
        func `Non-ASCII reports the offending byte position`() {

            do {
                _ = try Version.Semantic("1.0.0-α")
                Issue.record("expected throw")
            } catch let error {
                #expect(error.range.start.underlying.rawValue == 6)
                #expect(error.range.end.underlying.rawValue == 7)
            }
        }

        @Test
        func `Trailing bytes report range after consumed prefix`() {
            do {
                _ = try Version.Semantic("1.2.3.4")
                Issue.record("expected throw")
            } catch let error {

                #expect(error.range.start.underlying.rawValue == 5)
                #expect(error.range.end.underlying.rawValue == 7)
            }
        }

        @Test
        func `Empty pre-release reports the dash-following position`() {
            do {
                _ = try Version.Semantic("1.0.0-")
                Issue.record("expected throw")
            } catch let error {

                #expect(error.range.start.underlying.rawValue == 6)
            }
        }
    }
}
