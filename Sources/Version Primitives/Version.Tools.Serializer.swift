public import ASCII_Primitives
public import Serializer_Primitives

extension Version.Tools {

    public struct Serializer<Buffer: Swift.RangeReplaceableCollection>: Swift.Sendable
    where Buffer: Swift.Sendable, Buffer.Element == Byte {

        @inlinable
        public init() {}
    }
}

extension Version.Tools.Serializer: Serializer_Primitives.Serializer.`Protocol` {

    public typealias Output = Version.Tools

    public typealias Failure = Swift.Never

    @inlinable
    public func serialize(_ output: Version.Tools, into buffer: inout Buffer) {
        ASCII.Decimal.serialize(output.major.underlying, into: &buffer)
        buffer.append(0x2E)
        ASCII.Decimal.serialize(output.minor.underlying, into: &buffer)
        if let patch = output.patch {
            buffer.append(0x2E)
            ASCII.Decimal.serialize(patch.underlying, into: &buffer)
        }
    }
}
