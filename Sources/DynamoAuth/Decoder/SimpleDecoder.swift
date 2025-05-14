public struct SimpleDecoder<V>: Decoder, DecoderContainer {

  private let value: V?
  private let inverseMapper: any InverseMapper<V>

  public let codingPath: [any CodingKey]
  public let userInfo: [CodingUserInfoKey: Any]

  public init(
    codingPath: [any CodingKey],
    userInfo: [CodingUserInfoKey: Any],
    value: V?,
    inverseMapper: any InverseMapper<V>
  ) {
    self.codingPath = codingPath
    self.userInfo = userInfo
    self.value = value
    self.inverseMapper = inverseMapper
  }

  public func container<Key>(keyedBy type: Key.Type) throws -> KeyedDecodingContainer<Key>
  where Key: CodingKey {

    let map = try catchInverseMapper(value, inverseMapper.mapMap)

    let container = SimpleKeyedDecoder<V, Key>(
      codingPath: codingPath, map: map, inverseMapper: inverseMapper)
    return KeyedDecodingContainer(container)

  }

  public func unkeyedContainer() throws -> any UnkeyedDecodingContainer {

    let list = try catchInverseMapper(value, inverseMapper.mapList)

    return SimpleUnkeyedDecoder(
      codingPath: codingPath,
      list: list,
      inverseMapper: inverseMapper
    )
  }

  public func singleValueContainer() throws -> any SingleValueDecodingContainer {

    return SimpleSingleValueDecoder<V>(
      codingPath: codingPath,
      value: value,
      inverseMapper: inverseMapper
    )
  }

}
