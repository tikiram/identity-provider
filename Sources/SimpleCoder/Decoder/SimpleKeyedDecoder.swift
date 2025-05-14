import Foundation

struct SimpleKeyedDecoder<V, Key: CodingKey>: KeyedDecodingContainerProtocol, DecoderContainer {

  // -------------------------------------------------
  let codingPath: [any CodingKey]
  var allKeys: [Key] {
    return []
  }

  // -------------------------------------------------

  private let map: [String: V]
  private let inverseMapper: any InverseMapper<V>

  init(
    codingPath: [any CodingKey],
    map: [String: V],
    inverseMapper: any InverseMapper<V>
  ) {
    self.codingPath = codingPath
    self.map = map
    self.inverseMapper = inverseMapper
  }

  // -------------------------------------------------

  func decode<T>(_ type: T.Type, forKey key: Key) throws -> T where T: Decodable {

    if type == Date.self {
      return try catchInverseMapper(map[key.stringValue], inverseMapper.mapDate) as! T
    }

    let value = map[key.stringValue]

    let simpleDecoder = SimpleDecoder(
      codingPath: codingPath + [key],
      userInfo: [:],
      value: value,
      inverseMapper: inverseMapper
    )

    return try T(from: simpleDecoder)
  }

  func decode(_ type: UInt64.Type, forKey key: Key) throws -> UInt64 {
    return try catchInverseMapper(map[key.stringValue], inverseMapper.mapUInt64)
  }

  func decode(_ type: UInt32.Type, forKey key: Key) throws -> UInt32 {
    return try catchInverseMapper(map[key.stringValue], inverseMapper.mapUInt32)
  }

  func decode(_ type: UInt16.Type, forKey key: Key) throws -> UInt16 {
    return try catchInverseMapper(map[key.stringValue], inverseMapper.mapUInt16)
  }

  func decode(_ type: UInt8.Type, forKey key: Key) throws -> UInt8 {
    return try catchInverseMapper(map[key.stringValue], inverseMapper.mapUInt8)
  }

  func decode(_ type: UInt.Type, forKey key: Key) throws -> UInt {
    return try catchInverseMapper(map[key.stringValue], inverseMapper.mapUInt)
  }

  func decode(_ type: Int64.Type, forKey key: Key) throws -> Int64 {
    return try catchInverseMapper(map[key.stringValue], inverseMapper.mapInt64)
  }

  func decode(_ type: Int32.Type, forKey key: Key) throws -> Int32 {
    return try catchInverseMapper(map[key.stringValue], inverseMapper.mapInt32)
  }

  func decode(_ type: Int16.Type, forKey key: Key) throws -> Int16 {
    return try catchInverseMapper(map[key.stringValue], inverseMapper.mapInt16)
  }

  func decode(_ type: Int8.Type, forKey key: Key) throws -> Int8 {
    return try catchInverseMapper(map[key.stringValue], inverseMapper.mapInt8)
  }

  func decode(_ type: Int.Type, forKey key: Key) throws -> Int {
    return try catchInverseMapper(map[key.stringValue], inverseMapper.mapInt)
  }

  func decode(_ type: Float.Type, forKey key: Key) throws -> Float {
    return try catchInverseMapper(map[key.stringValue], inverseMapper.mapFloat)
  }

  func decode(_ type: Double.Type, forKey key: Key) throws -> Double {
    return try catchInverseMapper(map[key.stringValue], inverseMapper.mapDouble)
  }

  func decode(_ type: String.Type, forKey key: Key) throws -> String {
    return try catchInverseMapper(map[key.stringValue], inverseMapper.mapString)
  }

  func decode(_ type: Bool.Type, forKey key: Key) throws -> Bool {
    return try catchInverseMapper(map[key.stringValue], inverseMapper.mapBool)
  }

  func contains(_ key: Key) -> Bool {
    return map[key.stringValue] != nil
  }

  func decodeNil(forKey key: Key) throws -> Bool {
    return try catchInverseMapper(map[key.stringValue], inverseMapper.isNil)
  }

  // --------------------------------------------------

  func nestedContainer<NestedKey>(
    keyedBy type: NestedKey.Type,
    forKey key: Key
  ) throws -> KeyedDecodingContainer<NestedKey> where NestedKey: CodingKey {
    let map = try catchInverseMapper(map[key.stringValue], inverseMapper.mapMap)

    let container = SimpleKeyedDecoder<V, NestedKey>(
      codingPath: codingPath + [key],
      map: map,
      inverseMapper: inverseMapper
    )
    return KeyedDecodingContainer(container)
  }

  func nestedUnkeyedContainer(forKey key: Key) throws -> any UnkeyedDecodingContainer {
    let path = codingPath + [key]
    let list = try catchInverseMapper(map[key.stringValue], inverseMapper.mapList)

    return SimpleUnkeyedDecoder(
      codingPath: path,
      list: list,
      inverseMapper: inverseMapper
    )
  }

  // ----------------------------------

  func superDecoder() throws -> any Decoder {
    fatalError("not implemented")
  }

  func superDecoder(forKey key: Key) throws -> any Decoder {
    fatalError("not implemented")
  }

}
