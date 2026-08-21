#if !hasFeature(Embedded)
    extension Version.Semantic: Codable {

        @inlinable
        public init(from decoder: any Decoder) throws {
            let container = try decoder.singleValueContainer()
            let string = try container.decode(Swift.String.self)
            do throws(Self.Error) {
                self = try Version.Semantic(string)
            } catch {
                throw DecodingError.dataCorruptedError(
                    in: container,
                    debugDescription: "Invalid SemVer 2.0.0 string '\(string)': \(error)"
                )
            }
        }

        @inlinable
        public func encode(to encoder: any Encoder) throws {
            var container = encoder.singleValueContainer()
            try container.encode(self.description)
        }
    }
#endif
