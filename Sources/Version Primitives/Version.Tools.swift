public import Byte_Parser_Primitives
internal import Byte_Primitives_Standard_Library_Integration
internal import Parser_Primitives
public import Tagged_Primitives
public import Text_Primitives

extension Version {

    public struct Tools: Swift.Sendable, Swift.Hashable, Swift.Comparable, Swift
            .CustomStringConvertible, Swift.LosslessStringConvertible
    {

        public let major: Major.Value

        public let minor: Minor.Value

        public let patch: Patch.Value?

        @inlinable
        public init(
            major: Major.Value,
            minor: Minor.Value,
            patch: Patch.Value? = nil
        ) {
            self.major = major
            self.minor = minor
            self.patch = patch
        }

        public init(parsing toolsString: Swift.String) throws(Version.Tools.Error) {
            let totalBytes = Swift.UInt(toolsString.utf8.count)
            for (offset, byte) in toolsString.utf8.enumerated() where byte >= 0x80 {
                let position = Self.position(Swift.UInt(offset))
                throw .nonASCIICharacters(
                    input: toolsString,
                    range: Text.Range(start: position, end: Self.position(Swift.UInt(offset) + 1))
                )
            }
            var input = Byte.Input(utf8: toolsString)
            self = try Version.Tools.Parser().parse(&input)
            if !input.isEmpty {
                let remaining = Swift.UInt(input.count)
                let consumed = totalBytes - remaining
                throw .invalidToolsVersionIdentifierCount(
                    input: toolsString,
                    range: Text.Range(
                        start: Self.position(consumed),
                        end: Self.position(totalBytes)
                    )
                )
            }
        }

        @inlinable
        public init?(_ description: Swift.String) {
            do throws(Version.Tools.Error) {
                self = try .init(parsing: description)
            } catch {
                return nil
            }
        }
    }
}

extension Version.Tools {

    public var description: Swift.String {
        var buffer: [Byte] = []
        Version.Tools.Serializer<[Byte]>().serialize(self, into: &buffer)
        return Swift.String(decoding: buffer, as: Swift.UTF8.self)
    }

    @inlinable
    public static func < (lhs: Self, rhs: Self) -> Swift.Bool {
        if lhs.major != rhs.major { return lhs.major < rhs.major }
        if lhs.minor != rhs.minor { return lhs.minor < rhs.minor }
        let lp = lhs.patch?.underlying ?? 0
        let rp = rhs.patch?.underlying ?? 0
        return lp < rp
    }

    @inlinable
    package static func position(_ offset: Swift.UInt) -> Text.Position {
        Text.Position(_unchecked: Ordinal(offset))
    }
}
