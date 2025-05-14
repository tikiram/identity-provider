import Foundation

struct SimpleSingleValueDecoder<V>: SingleValueDecodingContainer, DecoderContainer {

  let codingPath: [any CodingKey]

  private let value: V?
  private let inverseMapper: any InverseMapper<V>

  init(
    codingPath: [any CodingKey],
    value: V?,
    inverseMapper: any InverseMapper<V>
  ) {
    self.codingPath = codingPath
    self.value = value
    self.inverseMapper = inverseMapper
  }

  func decode<T>(_ type: T.Type) throws -> T where T: Decodable {
    if type == Date.self {
      return try catchInverseMapper(value, inverseMapper.mapDate) as! T
    }

    let simpleDecoder = SimpleDecoder(
      codingPath: codingPath,
      userInfo: [:],
      value: value,
      inverseMapper: inverseMapper
    )

    return try T(from: simpleDecoder)
  }

  func decode(_ type: UInt64.Type) throws -> UInt64 {
    return try catchInverseMapper(value, inverseMapper.mapUInt64)
  }

  func decode(_ type: UInt32.Type) throws -> UInt32 {
    return try catchInverseMapper(value, inverseMapper.mapUInt32)
  }

  func decode(_ type: UInt16.Type) throws -> UInt16 {
    return try catchInverseMapper(value, inverseMapper.mapUInt16)
  }

  func decode(_ type: UInt8.Type) throws -> UInt8 {
    return try catchInverseMapper(value, inverseMapper.mapUInt8)
  }

  func decode(_ type: UInt.Type) throws -> UInt {
    return try catchInverseMapper(value, inverseMapper.mapUInt)
  }

  func decode(_ type: Int64.Type) throws -> Int64 {
    return try catchInverseMapper(value, inverseMapper.mapInt64)
  }

  func decode(_ type: Int32.Type) throws -> Int32 {
    return try catchInverseMapper(value, inverseMapper.mapInt32)
  }

  func decode(_ type: Int16.Type) throws -> Int16 {
    return try catchInverseMapper(value, inverseMapper.mapInt16)
  }

  func decode(_ type: Int8.Type) throws -> Int8 {
    return try catchInverseMapper(value, inverseMapper.mapInt8)
  }

  func decode(_ type: Int.Type) throws -> Int {
    return try catchInverseMapper(value, inverseMapper.mapInt)
  }

  func decode(_ type: Float.Type) throws -> Float {
    return try catchInverseMapper(value, inverseMapper.mapFloat)
  }

  func decode(_ type: Double.Type) throws -> Double {
    return try catchInverseMapper(value, inverseMapper.mapDouble)
  }

  func decode(_ type: String.Type) throws -> String {
    return try catchInverseMapper(value, inverseMapper.mapString)
  }

  func decode(_ type: Bool.Type) throws -> Bool {
    return try catchInverseMapper(value, inverseMapper.mapBool)
  }

  func decodeNil() -> Bool {
    if let value = value {
      return inverseMapper.isNil(value)
    }
    return true
  }
}
