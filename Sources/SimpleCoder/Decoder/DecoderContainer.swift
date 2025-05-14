
protocol DecoderContainer {
  var codingPath: [any CodingKey] { get }
}

extension DecoderContainer {
  func catchInverseMapper<V, R>(_ value: V?, _ action: (V) throws -> R) throws -> R {
    do {
      guard let value else {
        throw InverseMapperError.invalidType
      }
      return try action(value)
    } catch InverseMapperError.invalidType {
      throw DecodingError.typeMismatch(
        R.self,
        DecodingError.Context(codingPath: codingPath, debugDescription: "\(R.self) expected"))
    }
  }
}
