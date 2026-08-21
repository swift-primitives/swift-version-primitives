public import Byte_Parser_Primitives
internal import Byte_Primitives_Standard_Library_Integration
internal import Ordinal_Primitives
internal import Parser_Primitives
public import Tagged_Primitives
public import Text_Primitives
public import Time_Primitives

extension Version {

    public enum Calendar: Swift.Sendable, Swift.Hashable, Swift.Comparable, Swift
            .CustomStringConvertible, Swift.LosslessStringConvertible
    {

        case yearOnly(year: Time.Year, modifier: Swift.String? = nil)

        case yearMonth(year: Time.Year, month: Time.Month, modifier: Swift.String? = nil)

        case full(
            year: Time.Year,
            month: Time.Month,
            micro: Micro.Value,
            modifier: Swift.String? = nil
        )

        public init(parsing calverString: Swift.String) throws(Version.Calendar.Error) {
            let totalBytes = Swift.UInt(calverString.utf8.count)
            for (offset, byte) in calverString.utf8.enumerated() where byte >= 0x80 {
                let position = Self.position(Swift.UInt(offset))
                throw .nonASCIICharacters(
                    input: calverString,
                    range: Text.Range(start: position, end: Self.position(Swift.UInt(offset) + 1))
                )
            }
            var input = Byte.Input(utf8: calverString)
            self = try Version.Calendar.Parser().parse(&input)
            if !input.isEmpty {
                let remaining = Swift.UInt(input.count)
                let consumed = totalBytes - remaining
                let trailing = Swift.String(decoding: input, as: Swift.UTF8.self)
                throw .invalidCalendarIdentifier(
                    input: calverString,
                    identifier: trailing,
                    range: Text.Range(
                        start: Self.position(consumed),
                        end: Self.position(totalBytes)
                    )
                )
            }
        }

        @inlinable
        public init?(_ description: Swift.String) {
            do throws(Version.Calendar.Error) {
                self = try .init(parsing: description)
            } catch {
                return nil
            }
        }
    }
}

extension Version.Calendar {

    public var description: Swift.String {
        var buffer: [Byte] = []
        Version.Calendar.Serializer<[Byte]>().serialize(self, into: &buffer)
        return Swift.String(decoding: buffer, as: Swift.UTF8.self)
    }

    public static func < (lhs: Self, rhs: Self) -> Swift.Bool {
        let (ly, lm, lu, lmod) = lhs.normalized()
        let (ry, rm, ru, rmod) = rhs.normalized()
        if ly != ry { return ly < ry }
        if lm != rm { return lm < rm }
        if lu != ru { return lu < ru }
        switch (lmod, rmod) {
        case (nil, nil): return false
        case (nil, _?): return false
        case (_?, nil): return true
        case (let l?, let r?): return l < r
        }
    }

    @usableFromInline
    func normalized() -> (
        year: Swift.Int, month: Swift.Int, micro: Swift.Int, modifier: Swift.String?
    ) {
        switch self {
        case .yearOnly(let y, let mod):
            return (y.rawValue, 0, 0, mod)

        case .yearMonth(let y, let m, let mod):
            return (y.rawValue, m.rawValue, 0, mod)

        case .full(let y, let m, let micro, let mod):
            return (y.rawValue, m.rawValue, Swift.Int(micro.underlying), mod)
        }
    }

    @inlinable
    package static func position(_ offset: Swift.UInt) -> Text.Position {
        Text.Position(_unchecked: Ordinal(offset))
    }
}
