import Foundation

struct SimpleSingleValueEncodingContainer: SingleValueEncodingContainer {

  let codingPath: [any CodingKey]
  let valueIntention: ValueIntention

  // ---

  mutating func encode(_ value: UInt64) throws {
    valueIntention.set(value)
  }

  mutating func encode(_ value: UInt32) throws {
    valueIntention.set(value)
  }

  mutating func encode(_ value: UInt16) throws {
    valueIntention.set(value)
  }

  mutating func encode(_ value: UInt8) throws {
    valueIntention.set(value)
  }

  mutating func encode(_ value: UInt) throws {
    valueIntention.set(value)
  }

  mutating func encode(_ value: Int64) throws {
    valueIntention.set(value)
  }

  mutating func encode(_ value: Int32) throws {
    valueIntention.set(value)
  }

  mutating func encode(_ value: Int16) throws {
    valueIntention.set(value)
  }

  mutating func encode(_ value: Int8) throws {
    valueIntention.set(value)
  }

  mutating func encode(_ value: Int) throws {
    valueIntention.set(value)
  }

  mutating func encode(_ value: Float) throws {
    valueIntention.set(value)
  }

  mutating func encode(_ value: Double) throws {
    valueIntention.set(value)
  }

  mutating func encode(_ value: String) throws {
    valueIntention.set(value)
  }

  mutating func encode(_ value: Bool) throws {
    valueIntention.set(value)
  }

  mutating func encodeNil() throws {
    valueIntention.setNil()
  }

  mutating func encode<T>(_ value: T) throws where T: Encodable {
    if let date = value as? Date {
      valueIntention.set(date)
      return
    }

    let encoder = SimpleEncoder(codingPath: codingPath, userInfo: [:])
    try value.encode(to: encoder)
    valueIntention.set(encoder.valueIntention)
  }
}
