public struct SimpleEncoder: Encoder {

    public let codingPath: [any CodingKey]
    public let userInfo: [CodingUserInfoKey: Any]

    public init(
        codingPath: [any CodingKey],
        userInfo: [CodingUserInfoKey: Any],
    ) {
        self.codingPath = codingPath
        self.userInfo = userInfo
    }

    public let valueIntention: ValueIntention = ValueIntention()

    public func container<Key>(keyedBy type: Key.Type)
        -> KeyedEncodingContainer<Key> where Key: CodingKey
    {
        let mapIntention = MapIntention(path: codingPath)
        self.valueIntention.set(mapIntention)

        let container = SimpleKeyedEncodingContainer<Key>(
            codingPath: codingPath,
            mapIntention: mapIntention
        )

        return KeyedEncodingContainer(container)
    }

    public func unkeyedContainer() -> any UnkeyedEncodingContainer {

        let localListIntention = ListIntention(path: codingPath)
        self.valueIntention.set(localListIntention)

        return SimpleUnkeyedEncodingContainer(
            codingPath: codingPath,
            listIntention: localListIntention
        )
    }

    public func singleValueContainer() -> any SingleValueEncodingContainer {
        return SimpleSingleValueEncodingContainer(
            codingPath: codingPath, valueIntention: valueIntention)
    }

}
