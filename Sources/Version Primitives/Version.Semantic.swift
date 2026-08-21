public import Byte_Parser_Primitives
internal import Byte_Primitives_Standard_Library_Integration
internal import Ordinal_Primitives
internal import Parser_Primitives
public import Tagged_Primitives
public import Text_Primitives

extension Version {

    public struct Semantic: Swift.Sendable, Swift.Hashable, Swift.Comparable, Swift
            .CustomStringConvertible
    {

        public let major: Major.Value

        public let minor: Minor.Value

        public let patch: Patch.Value

        public let preReleaseIdentifiers: [Identifier]

        public let buildMetadataIdentifiers: [Swift.String]

        public init(
            major: Major.Value,
            minor: Minor.Value,
            patch: Patch.Value,
            preReleaseIdentifiers: [Identifier] = [],
            buildMetadataIdentifiers: [Swift.String] = []
        ) {
            self.major = major
            self.minor = minor
            self.patch = patch
            self.preReleaseIdentifiers = preReleaseIdentifiers
            self.buildMetadataIdentifiers = buildMetadataIdentifiers
        }

        public init(parsing versionString: Swift.String) throws(Version.Semantic.Error) {
            let totalBytes = Swift.UInt(versionString.utf8.count)
            var firstNonASCII: Swift.UInt?
            for (offset, byte) in versionString.utf8.enumerated() where byte >= 0x80 {
                firstNonASCII = Swift.UInt(offset)
                break
            }
            if let firstNonASCII {
                throw .nonASCIICharacters(
                    input: versionString,
                    range: Text.Range(
                        start: Self.position(firstNonASCII),
                        end: Self.position(firstNonASCII + 1)
                    )
                )
            }
            var input = Byte.Input(utf8: versionString)
            self = try Version.Semantic.Parser().parse(&input)
            if !input.isEmpty {
                let remaining = Swift.UInt(input.count)
                let consumed = totalBytes - remaining
                let trailing = Swift.String(decoding: input, as: Swift.UTF8.self)
                let trailingRange = Text.Range(
                    start: Self.position(consumed),
                    end: Self.position(totalBytes)
                )
                if input.first == 0x2E {
                    throw .invalidVersionCoreIdentifierCount(
                        input: versionString,
                        found: Self.countDots(in: versionString) + 1,
                        range: trailingRange
                    )
                }
                throw .invalidVersionCoreIdentifier(
                    input: versionString,
                    identifier: trailing,
                    range: trailingRange
                )
            }
        }

    }
}

extension Version.Semantic {
    @inlinable
    package static func position(_ offset: Swift.UInt) -> Text.Position {
        Text.Position(_unchecked: Ordinal(offset))
    }

    private static func countDots(in s: Swift.String) -> Swift.Int {
        var count = 0
        for byte in s.utf8 where byte == 0x2E {
            count += 1
        }
        return count
    }

    public var description: Swift.String {
        var buffer: [Byte] = []
        Version.Semantic.Serializer<[Byte]>().serialize(self, into: &buffer)
        return Swift.String(decoding: buffer, as: Swift.UTF8.self)
    }

    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.major == rhs.major
            && lhs.minor == rhs.minor
            && lhs.patch == rhs.patch
            && lhs.preReleaseIdentifiers == rhs.preReleaseIdentifiers
    }

    public func hash(into hasher: inout Swift.Hasher) {
        hasher.combine(self.major)
        hasher.combine(self.minor)
        hasher.combine(self.patch)
        hasher.combine(self.preReleaseIdentifiers)
    }

    public static func < (lhs: Self, rhs: Self) -> Bool {
        if lhs.major != rhs.major { return lhs.major < rhs.major }
        if lhs.minor != rhs.minor { return lhs.minor < rhs.minor }
        if lhs.patch != rhs.patch { return lhs.patch < rhs.patch }

        switch (lhs.preReleaseIdentifiers.isEmpty, rhs.preReleaseIdentifiers.isEmpty) {
        case (true, true): return false

        case (true, false): return false

        case (false, true): return true

        case (false, false):
            return Self.compareIdentifiers(lhs.preReleaseIdentifiers, rhs.preReleaseIdentifiers)
        }
    }

    private static func compareIdentifiers(_ lhs: [Identifier], _ rhs: [Identifier]) -> Bool {
        for (l, r) in zip(lhs, rhs) {
            if l == r { continue }
            return l < r
        }

        return lhs.count < rhs.count
    }
}
