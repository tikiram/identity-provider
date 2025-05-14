import Foundation

struct IndexKey: CodingKey {
  let stringValue: String
  let intValue: Int?

  init?(stringValue: String) {
    fatalError("Not implemented")
  }
  init?(intValue: Int) {
    self.intValue = intValue
    self.stringValue = intValue.description
  }
}

class SimpleUnkeyedDecoder<V>: UnkeyedDecodingContainer, DecoderContainer {

  let codingPath: [any CodingKey]
  let count: Int?
  private(set) var isAtEnd: Bool
  private(set) var currentIndex: Int

  private let list: [V]
  private let inverseMapper: any InverseMapper<V>

  public init(
    codingPath: [any CodingKey],
    list: [V],
    inverseMapper: any InverseMapper<V>
  ) {
    self.codingPath = codingPath
    self.count = list.count
    self.isAtEnd = false
    self.currentIndex = 0
    self.list = list
    self.inverseMapper = inverseMapper
  }

  func decode<T>(_ type: T.Type) throws -> T where T: Decodable {
    if type == Date.self {
      return try process(inverseMapper.mapDate) as! T
    }

    let simpleDecoder = SimpleDecoder(
      codingPath: codingPath + [IndexKey(intValue: currentIndex)!],
      userInfo: [:],
      value: getValue(),
      inverseMapper: inverseMapper
    )

    return try T(from: simpleDecoder)
  }

  func decode(_ type: UInt64.Type) throws -> UInt64 {
    return try process(inverseMapper.mapUInt64)
  }

  func decode(_ type: UInt32.Type) throws -> UInt32 {
    return try process(inverseMapper.mapUInt32)
  }

  func decode(_ type: UInt16.Type) throws -> UInt16 {
    return try process(inverseMapper.mapUInt16)
  }

  func decode(_ type: UInt8.Type) throws -> UInt8 {
    return try process(inverseMapper.mapUInt8)
  }

  func decode(_ type: UInt.Type) throws -> UInt {
    return try process(inverseMapper.mapUInt)
  }

  func decode(_ type: Int64.Type) throws -> Int64 {
    return try process(inverseMapper.mapInt64)
  }

  func decode(_ type: Int32.Type) throws -> Int32 {
    return try process(inverseMapper.mapInt32)
  }

  func decode(_ type: Int16.Type) throws -> Int16 {
    return try process(inverseMapper.mapInt16)
  }

  func decode(_ type: Int8.Type) throws -> Int8 {
    return try process(inverseMapper.mapInt8)
  }

  func decode(_ type: Int.Type) throws -> Int {
    return try process(inverseMapper.mapInt)
  }

  func decode(_ type: Float.Type) throws -> Float {
    return try process(inverseMapper.mapFloat)
  }

  func decode(_ type: Double.Type) throws -> Double {
    return try process(inverseMapper.mapDouble)
  }

  func decode(_ type: String.Type) throws -> String {
    return try process(inverseMapper.mapString)
  }

  func decode(_ type: Bool.Type) throws -> Bool {
    return try process(inverseMapper.mapBool)
  }

  func decodeNil() throws -> Bool {
    let value = list[currentIndex]
    let isValueNil = inverseMapper.isNil(value)
    if isValueNil {
      currentIndex += 1
      if currentIndex >= (count ?? 0) {
        isAtEnd = true
      }
    }
    return isValueNil

  }

  func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type) throws
    -> KeyedDecodingContainer<NestedKey> where NestedKey: CodingKey
  {
    let path = codingPath + [IndexKey(intValue: currentIndex)!]

    let map = try catchInverseMapper(getValue(), inverseMapper.mapMap)
    let container = SimpleKeyedDecoder<V, NestedKey>(
      codingPath: path,
      map: map,
      inverseMapper: inverseMapper
    )
    return KeyedDecodingContainer(container)
  }

  func nestedUnkeyedContainer() throws -> any UnkeyedDecodingContainer {
    let path = codingPath + [IndexKey(intValue: currentIndex)!]
    let nestedList = try catchInverseMapper(getValue(), inverseMapper.mapList)

    return SimpleUnkeyedDecoder(
      codingPath: path,
      list: nestedList,
      inverseMapper: inverseMapper
    )
  }

  func superDecoder() throws -> any Decoder {
    fatalError("Not implemented")
  }

  // ---------------------------------------------------

  func process<R>(_ action: (V) throws -> R) throws -> R {
    return try catchInverseMapper(getValue(), action)
  }

  func getValue() -> V {
    let value = list[currentIndex]
    currentIndex += 1
    if currentIndex >= (count ?? 0) {
      isAtEnd = true
    }
    return value
  }

}
