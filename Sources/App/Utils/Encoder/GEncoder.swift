



// class Intention<R> {

//     private let valueMapper: any ValueMapper<R>
//     private var resultable: (any Resultable<R>)?

//     init(_ valueMapper: any ValueMapper<R>) {
//         self.valueMapper = valueMapper
//         self.resultable = nil
//     }

//     func mapIntention() -> MapIntention<R> {
//         let localMapIntention = MapIntention<R>(valueMapper)
//         self.resultable = localMapIntention
//         return localMapIntention
//     }

//     func result() -> R {
//         guard let resultable = self.resultable else {
//             fatalError("This shouldn't happen")
//         }
//         return resultable.toResult()
//     }

// }

class OGEncoder<R>: Encoder {

    let codingPath: [any CodingKey]
    let userInfo: [CodingUserInfoKey: Any]
    let valueMapper: any ValueMapper<R>

    private var mapIntention: MapIntention<R>? = nil

    init(
        codingPath: [any CodingKey],
        userInfo: [CodingUserInfoKey: Any],
        valueMapper: any ValueMapper<R>
    ) {
        self.codingPath = codingPath
        self.userInfo = userInfo

    }

    func getMap() -> [String: R]? {
        return self.mapIntention?.createMap()
    }

    func container<Key>(keyedBy type: Key.Type) -> KeyedEncodingContainer<Key>
    where Key: CodingKey {

        print("encoder - 1 - container: \(codingPath)")

        let localMapIntention = MapIntention()
        self.mapIntention = localMapIntention

        let container = OGKeyedEncodingContainer<R, Key>(
            mapIntention: localMapIntention,
            codingPath: codingPath)

        return KeyedEncodingContainer(container)
    }

    func unkeyedContainer() -> any UnkeyedEncodingContainer {

        print("encoder - 2 - unkeyed: \(codingPath)")

        let localListIntention = ListIntention<R>(valueMapper)

        return OGUnkeyedEncodingContainer<R>(
            codingPath: codingPath,
            listIntention: localListIntention
        )
    }

    func singleValueContainer() -> any SingleValueEncodingContainer {
        print("encoder - 3 - single value: \(codingPath)")

        return OGSingleValue<R>(codingPath: codingPath)
    }

}

struct OGSingleValue<R>: SingleValueEncodingContainer {

    let valueIntention: ValueIntention

    let codingPath: [any CodingKey]

    // ---

    mutating func encode<T>(_ value: T) throws where T: Encodable {
        let encoder = OGEncoder<R>(codingPath: codingPath, userInfo: [:])
        try value.encode(to: encoder)
    }

    mutating func encode(_ value: UInt64) throws {

    }

    mutating func encode(_ value: UInt32) throws {

    }

    mutating func encode(_ value: UInt16) throws {

    }

    mutating func encode(_ value: UInt8) throws {

    }

    mutating func encode(_ value: UInt) throws {

    }

    mutating func encode(_ value: Int64) throws {

    }

    mutating func encode(_ value: Int32) throws {

    }

    mutating func encode(_ value: Int16) throws {

    }

    mutating func encode(_ value: Int8) throws {

    }

    mutating func encode(_ value: Int) throws {
        print("Single Value Encoding")
        print(codingPath)
        print(value)

    }

    mutating func encode(_ value: Float) throws {

    }

    mutating func encode(_ value: Double) throws {

    }

    mutating func encode(_ value: String) throws {

    }

    mutating func encode(_ value: Bool) throws {

    }

    mutating func encodeNil() throws {

    }
}

struct OGKeyedEncodingContainer<R, Key: CodingKey>: KeyedEncodingContainerProtocol {

    let mapIntention: MapIntention

    let codingPath: [any CodingKey]
    // -------------

    mutating func encodeNil(forKey key: Key) throws {

    }

    mutating func encode(_ value: UInt64, forKey key: Key) throws {

    }

    mutating func encode(_ value: UInt32, forKey key: Key) throws {

    }

    mutating func encode(_ value: UInt16, forKey key: Key) throws {

    }

    mutating func encode(_ value: UInt8, forKey key: Key) throws {

    }

    mutating func encode(_ value: UInt, forKey key: Key) throws {

    }

    mutating func encode(_ value: Int64, forKey key: Key) throws {

    }

    mutating func encode(_ value: Int32, forKey key: Key) throws {

    }

    mutating func encode(_ value: Int16, forKey key: Key) throws {

    }

    mutating func encode(_ value: Int8, forKey key: Key) throws {

    }

    mutating func encode<T>(_ value: T, forKey key: Key) throws where T: Encodable {

        let encoder = OGEncoder<R>(
            codingPath: codingPath + [key],
            userInfo: [:],
            valueMapper: mapIntention.valueMapper
        )

        try value.encode(to: encoder)

        if let result = encoder.getMap() {
            mapIntention.set(key.stringValue, result)
        }

    }

    mutating func encode(_ value: Int, forKey key: Key) throws {
        mapIntention.set(key.stringValue, value)
    }

    mutating func encode(_ value: Float, forKey key: Key) throws {

    }

    mutating func encode(_ value: Double, forKey key: Key) throws {

    }

    mutating func encode(_ value: String, forKey key: Key) throws {

    }

    mutating func encode(_ value: Bool, forKey key: Key) throws {

    }

    mutating func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type, forKey key: Key)
        -> KeyedEncodingContainer<NestedKey> where NestedKey: CodingKey
    {
        print("keyed - 1 - nested container")

        let childMapIntention = MapIntention()

        mapIntention.set(key.stringValue, childMapIntention)

        let container = OGKeyedEncodingContainer<R, NestedKey>(
            mapIntention: childMapIntention,
            codingPath: codingPath + [key])

        return KeyedEncodingContainer(container)
    }

    mutating func nestedUnkeyedContainer(forKey key: Key) -> any UnkeyedEncodingContainer {
        print("keyed - 2 - nested unkeyed")
        return OGUnkeyedEncodingContainer<R>(codingPath: codingPath + [key])
    }

    mutating func superEncoder() -> any Encoder {
        // ?
        print("keyed - 3 - super encoder")
        let superKey = Key(stringValue: "super")!
        return superEncoder(forKey: superKey)
    }

    mutating func superEncoder(forKey key: Key) -> any Encoder {
        print("keyyed - 4 - super encoder")
        return OGEncoder<R>(
            codingPath: codingPath + [key], userInfo: [:], valueMapper: mapIntention.valueMapper)
    }

}

struct OGUnkeyedEncodingContainer<R>: UnkeyedEncodingContainer {
    let codingPath: [any CodingKey]
    let listIntention: ListIntention<R>

    private(set) var count: Int = 0

    mutating func encode<T>(_ value: T) throws where T: Encodable {
        let encoder = OGEncoder<R>(codingPath: codingPath + [nextIndexedKey()], userInfo: [:])
        try value.encode(to: encoder)
    }

    mutating func encode(_ value: UInt64) throws {

    }

    mutating func encode(_ value: UInt32) throws {

    }

    mutating func encode(_ value: UInt16) throws {

    }

    mutating func encode(_ value: UInt8) throws {

    }

    mutating func encode(_ value: UInt) throws {

    }

    mutating func encode(_ value: Int64) throws {

    }

    mutating func encode(_ value: Int32) throws {

    }

    mutating func encode(_ value: Int16) throws {

    }

    mutating func encode(_ value: Int8) throws {

    }

    mutating func encode(_ value: Int) throws {

        let key = codingPath + [nextIndexedKey()]
        print("Unkeyed encoding container")
        print(key)
        print(value)

    }

    mutating func encode(_ value: Float) throws {

    }

    mutating func encode(_ value: Double) throws {

    }

    mutating func encode(_ value: String) throws {

    }

    mutating func encode(_ value: Bool) throws {

    }

    mutating func encodeNil() throws {

    }

    mutating func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type)
        -> KeyedEncodingContainer<NestedKey> where NestedKey: CodingKey
    {

        print("unkeyed - 1 - container")

        let container = OGKeyedEncodingContainer<R, NestedKey>(
            codingPath: codingPath + [nextIndexedKey()]
        )

        return KeyedEncodingContainer(container)
    }

    mutating func nestedUnkeyedContainer() -> any UnkeyedEncodingContainer {

        print("unkeyed - 2 - container")

        return OGUnkeyedEncodingContainer(codingPath: codingPath + [nextIndexedKey()])
    }

    mutating func superEncoder() -> any Encoder {

        print("unkeyed - 3 super")

        return OGEncoder<R>(codingPath: [nextIndexedKey()], userInfo: [:])
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
