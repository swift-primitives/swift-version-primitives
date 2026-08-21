public import ASCII_Primitives
public import Serializer_Primitives
public import Time_Primitives

extension Version.Calendar {

    public struct Serializer<Buffer: Swift.RangeReplaceableCollection>: Swift.Sendable
    where Buffer: Swift.Sendable, Buffer.Element == Byte {

        @inlinable
        public init() {}
    }
}

extension Version.Calendar.Serializer: Serializer_Primitives.Serializer.`Protocol` {

    public typealias Output = Version.Calendar

    public typealias Failure = Swift.Never

    @inlinable
    public func serialize(_ output: Version.Calendar, into buffer: inout Buffer) {
        switch output {
        case .yearOnly(let year, let modifier):
            ASCII.Decimal.serialize(Swift.UInt(year.rawValue), into: &buffer)
            Self.appendModifier(modifier, into: &buffer)

        case .yearMonth(let year, let month, let modifier):
            ASCII.Decimal.serialize(Swift.UInt(year.rawValue), into: &buffer)
            buffer.append(0x2E)
            Self.appendPadded(Swift.UInt(month.rawValue), into: &buffer)
            Self.appendModifier(modifier, into: &buffer)

        case .full(let year, let month, let micro, let modifier):
            ASCII.Decimal.serialize(Swift.UInt(year.rawValue), into: &buffer)
            buffer.append(0x2E)
            Self.appendPadded(Swift.UInt(month.rawValue), into: &buffer)
            buffer.append(0x2E)
            Self.appendPadded(micro.underlying, into: &buffer)
            Self.appendModifier(modifier, into: &buffer)
        }
    }

    @inlinable
    package static func appendPadded(_ value: Swift.UInt, into buffer: inout Buffer) {
        if value < 10 {
            buffer.append(0x30)
        }
        ASCII.Decimal.serialize(value, into: &buffer)
    }

    @inlinable
    package static func appendModifier(_ modifier: Swift.String?, into buffer: inout Buffer) {
        if let modifier {
            buffer.append(0x2D)
            buffer.append(contentsOf: modifier.utf8.lazy.map(Byte.init))
        }
    }
}
