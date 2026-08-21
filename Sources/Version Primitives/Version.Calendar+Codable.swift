#if !hasFeature(Embedded)
    extension Version.Calendar: Codable {

        @inlinable
        public init(from decoder: any Decoder) throws {
            let container = try decoder.singleValueContainer()
            let string = try container.decode(Swift.String.self)
            do throws(Self.Error) {
                self = try Version.Calendar(parsing: string)
            } catch {
                throw DecodingError.dataCorruptedError(
                    in: container,
                    debugDescription: "Invalid CalVer string '\(string)': \(error)"
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
