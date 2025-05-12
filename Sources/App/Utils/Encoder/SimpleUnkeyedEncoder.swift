struct SimpleUnkeyedEncodingContainer: UnkeyedEncodingContainer {
  let codingPath: [any CodingKey]
  let listIntention: ListIntention

  private(set) var count: Int = 0

  // --------------------------------------------------

  mutating func encode(_ value: UInt64) throws {
    let _ = nextIndexedKey()
    listIntention.add(value)
  }
  mutating func encode(_ value: UInt32) throws {
    let _ = nextIndexedKey()
    listIntention.add(value)
  }
  mutating func encode(_ value: UInt16) throws {
    let _ = nextIndexedKey()
    listIntention.add(value)
  }
  mutating func encode(_ value: UInt8) throws {
    let _ = nextIndexedKey()
    listIntention.add(value)
  }
  mutating func encode(_ value: UInt) throws {
    let _ = nextIndexedKey()
    listIntention.add(value)
  }
  mutating func encode(_ value: Int64) throws {
    let _ = nextIndexedKey()
    listIntention.add(value)
  }
  mutating func encode(_ value: Int32) throws {
    let _ = nextIndexedKey()
    listIntention.add(value)
  }
  mutating func encode(_ value: Int16) throws {
    let _ = nextIndexedKey()
    listIntention.add(value)
  }
  mutating func encode(_ value: Int8) throws {
    let _ = nextIndexedKey()
    listIntention.add(value)
  }
  mutating func encode(_ value: Int) throws {
    let _ = nextIndexedKey()
    listIntention.add(value)
  }
  mutating func encode(_ value: Float) throws {
    let _ = nextIndexedKey()
    listIntention.add(value)
  }
  mutating func encode(_ value: Double) throws {
    let _ = nextIndexedKey()
    listIntention.add(value)
  }
  mutating func encode(_ value: String) throws {
    let _ = nextIndexedKey()
    listIntention.add(value)
  }
  mutating func encode(_ value: Bool) throws {
    let _ = nextIndexedKey()
    listIntention.add(value)
  }
  mutating func encodeNil() throws {
    let _ = nextIndexedKey()
    listIntention.addNil()
  }
  mutating func encode<T>(_ value: T) throws where T: Encodable {
    let encoder = SimpleEncoder(codingPath: codingPath + [nextIndexedKey()], userInfo: [:])
    try value.encode(to: encoder)
    listIntention.add(encoder.valueIntention)
  }

  // =====================================================================

  mutating func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type)
    -> KeyedEncodingContainer<NestedKey> where NestedKey: CodingKey
  {

    let path = codingPath + [nextIndexedKey()]

    let mapIntention = MapIntention(path: path)
    listIntention.add(mapIntention)

    let container = SimpleKeyedEncodingContainer<NestedKey>(
      codingPath: path,
      mapIntention: mapIntention
    )

    return KeyedEncodingContainer(container)
  }

  mutating func nestedUnkeyedContainer() -> any UnkeyedEncodingContainer {

    let path = codingPath + [nextIndexedKey()]

    let listIntention = ListIntention(path: path)
    listIntention.add(listIntention)

    return SimpleUnkeyedEncodingContainer(
      codingPath: path,
      listIntention: listIntention
    )
  }

  mutating func superEncoder() -> any Encoder {
    fatalError("superEncoder not implemented")
    // return OGEncoder<R>(codingPath: [nextIndexedKey()], userInfo: [:])
  }

  // ?

  private mutating func nextIndexedKey() -> CodingKey {
    let nextCodingKey = IndexedCodingKey(intValue: count)!
    count += 1
    return nextCodingKey
  }
  private struct IndexedCodingKey: CodingKey {
    let intValue: Int?
    let stringValue: String

    init?(intValue: Int) {
      self.intValue = intValue
      self.stringValue = intValue.description
    }

    init?(stringValue: String) {
      return nil
    }
  }

}
