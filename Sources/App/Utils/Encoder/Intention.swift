protocol ValueMapper<R> {
    associatedtype R

    func map(_ value: Int) -> R
    func map(_ value: String) -> R
    func map(_ value: Bool) -> R
    func map(_ value: Double) -> R
    func map(_ value: Float) -> R
    func map(_ value: [R]) -> R
    func map(_ value: [String: R]) -> R
    func mapNil() -> R

}

protocol Intention {
    func result<R>(_ valueMapper: any ValueMapper<R>) throws -> R
}

class ListIntention<R> {

    public let valueMapper: any ValueMapper<R>

    init(_ valueMapper: any ValueMapper<R>) {
        self.valueMapper = valueMapper
    }

    func setFutureMap(_ index: Int) -> MapIntention<R> {
        let childMapIntention = MapIntention<R>(valueMapper)
        // children[key] = childMapIntention
        return childMapIntention
    }

    // func result() throws -> R {

    // }
}

extension Int: Intention {
    func result<R>(_ valueMapper: any ValueMapper<R>) throws -> R {
        return valueMapper.map(self)
    }
}

class ValueIntention: Intention {
    private var value: Intention? = nil

    func set(intention: Intention) {
        self.value = intention
    }

    func result<R>(_ valueMapper: any ValueMapper<R>) throws -> R {
        guard let value else {
            fatalError()
        }
        return try value.result(valueMapper)
    }
}

// struct IntIntention: Intention {
//     let value: Int

//     func result<R>(_ valueMapper: any ValueMapper<R>) throws -> R {
//         return valueMapper.map(value)
//     }
// }

class MapIntention: Intention {
    private var map: [String: Intention] = [:]

    func createMap() -> [String: String] {
        // let pendingEntries = children.mapValues { mapIntention in
        //     let resultMap = mapIntention.createMap()
        //     let result = valueMapper.map(resultMap)
        //     return result
        // }
        // return map.merging(pendingEntries) { (_, new) in new }
        return [:]
    }

    func result<R>(_ valueMapper: any ValueMapper<R>) throws -> R {

    }

    // func result() -> R {
    //     let map = createMap()
    //     return valueMapper.map(map)
    // }

    func set(_ key: String, _ value: Intention) {
        map[key] = value
    }
}
