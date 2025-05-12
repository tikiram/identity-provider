

class SimpleEncoder: Encoder {

    let codingPath: [any CodingKey]
    let userInfo: [CodingUserInfoKey: Any]

    init(
        codingPath: [any CodingKey],
        userInfo: [CodingUserInfoKey: Any],
    ) {
        self.codingPath = codingPath
        self.userInfo = userInfo
    }

    let valueIntention: ValueIntention = ValueIntention()

    func container<Key>(keyedBy type: Key.Type)
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

    func unkeyedContainer() -> any UnkeyedEncodingContainer {

        let localListIntention = ListIntention(path: codingPath)
        self.valueIntention.set(localListIntention)

        return SimpleUnkeyedEncodingContainer(
            codingPath: codingPath,
            listIntention: localListIntention
        )
    }

    func singleValueContainer() -> any SingleValueEncodingContainer {
        return SimpleSingleValueEncodingContainer(codingPath: codingPath, valueIntention: valueIntention)
    }

}
