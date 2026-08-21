public import ASCII_Primitives
public import Serializer_Primitives

extension Version.Semantic {

    public struct Serializer<Buffer: Swift.RangeReplaceableCollection>: Swift.Sendable
    where Buffer: Swift.Sendable, Buffer.Element == Byte {

        @inlinable
        public init() {}
    }
}

extension Version.Semantic.Serializer: Serializer_Primitives.Serializer.`Protocol` {

    public typealias Output = Version.Semantic

    public typealias Failure = Swift.Never

    @inlinable
    public func serialize(_ output: Version.Semantic, into buffer: inout Buffer) {
        ASCII.Decimal.serialize(output.major.underlying, into: &buffer)
        buffer.append(0x2E)
        ASCII.Decimal.serialize(output.minor.underlying, into: &buffer)
        buffer.append(0x2E)
        ASCII.Decimal.serialize(output.patch.underlying, into: &buffer)

        if !output.preReleaseIdentifiers.isEmpty {
            buffer.append(0x2D)
            for (index, identifier) in output.preReleaseIdentifiers.enumerated() {
                if index > 0 {
                    buffer.append(0x2E)
                }
                switch identifier {
                case .numeric(let value):
                    ASCII.Decimal.serialize(value, into: &buffer)

                case .alphanumeric(let text):
                    buffer.append(contentsOf: text.utf8.lazy.map(Byte.init))
                }
            }
        }

        if !output.buildMetadataIdentifiers.isEmpty {
            buffer.append(0x2B)
            for (index, identifier) in output.buildMetadataIdentifiers.enumerated() {
                if index > 0 {
                    buffer.append(0x2E)
                }
                buffer.append(contentsOf: identifier.utf8.lazy.map(Byte.init))
            }
        }
    }
}
