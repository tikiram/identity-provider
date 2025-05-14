import Foundation

struct SimpleKeyedEncodingContainer<Key: CodingKey>: KeyedEncodingContainerProtocol {

  let codingPath: [any CodingKey]
  let mapIntention: MapIntention

  // -------------

  mutating func encodeNil(forKey key: Key) throws {
    mapIntention.setNil(key)
  }
  mutating func encode(_ value: UInt64, forKey key: Key) throws {
    mapIntention.set(key, value)
  }
  mutating func encode(_ value: UInt32, forKey key: Key) throws {
    mapIntention.set(key, value)
  }
  mutating func encode(_ value: UInt16, forKey key: Key) throws {
    mapIntention.set(key, value)
  }
  mutating func encode(_ value: UInt8, forKey key: Key) throws {
    mapIntention.set(key, value)
  }
  mutating func encode(_ value: UInt, forKey key: Key) throws {
    mapIntention.set(key, value)
  }
  mutating func encode(_ value: Int64, forKey key: Key) throws {
    mapIntention.set(key, value)
  }
  mutating func encode(_ value: Int32, forKey key: Key) throws {
    mapIntention.set(key, value)
  }
  mutating func encode(_ value: Int16, forKey key: Key) throws {
    mapIntention.set(key, value)
  }
  mutating func encode(_ value: Int8, forKey key: Key) throws {
    mapIntention.set(key, value)
  }
  mutating func encode(_ value: Int, forKey key: Key) throws {
    mapIntention.set(key, value)
  }
  mutating func encode(_ value: Float, forKey key: Key) throws {
    mapIntention.set(key, value)
  }
  mutating func encode(_ value: Double, forKey key: Key) throws {
    mapIntention.set(key, value)
  }
  mutating func encode(_ value: String, forKey key: Key) throws {
    mapIntention.set(key, value)
  }
  mutating func encode(_ value: Bool, forKey key: Key) throws {
    mapIntention.set(key, value)
  }
  mutating func encode<T>(_ value: T, forKey key: Key) throws where T: Encodable {
    if let date = value as? Date {
      mapIntention.set(key, date)
      return
    }

    let encoder = SimpleEncoder(
      codingPath: codingPath + [key],
      userInfo: [:]
    )
    try value.encode(to: encoder)

    mapIntention.set(key, encoder.valueIntention)
  }

  // ===============================================================================================

  mutating func nestedContainer<NestedKey>(
    keyedBy keyType: NestedKey.Type,
    forKey key: Key
  ) -> KeyedEncodingContainer<NestedKey> where NestedKey: CodingKey {

    let path = codingPath + [key]

    let childMapIntention = MapIntention(path: path)
    mapIntention.set(key, childMapIntention)

    let container = SimpleKeyedEncodingContainer<NestedKey>(
      codingPath: path,
      mapIntention: childMapIntention
    )

    return KeyedEncodingContainer(container)
  }

  mutating func nestedUnkeyedContainer(forKey key: Key) -> any UnkeyedEncodingContainer {

    let path = codingPath + [key]

    let listIntention = ListIntention(path: path)
    mapIntention.set(key, listIntention)

    let container = SimpleUnkeyedEncodingContainer(
      codingPath: path,
      listIntention: listIntention
    )

    return container
  }

  mutating func superEncoder(forKey key: Key) -> any Encoder {
    // return OGEncoder<R>(
    //     codingPath: codingPath + [key], userInfo: [:])
    fatalError("superEncoder not implemented")
  }

  mutating func superEncoder() -> any Encoder {
    // let superKey = Key(stringValue: "super")!
    // return superEncoder(forKey: superKey)
    fatalError("superEncoder not implemented")
  }
}
