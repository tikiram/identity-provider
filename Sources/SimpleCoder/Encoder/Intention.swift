protocol Intention {
    func result<R>(_ valueMapper: any ValueMapper<R>) throws -> R
}

enum IntentionError: Error {
    case emptyIntention
}

class ListIntention: Intention {
    private let path: [any CodingKey]
    private var list: [Intention] = []

    init(path: [any CodingKey]) {
        self.path = path
    }

    func result<R>(_ valueMapper: any ValueMapper<R>) throws -> R {
        let result = try list.map { try $0.result(valueMapper) }
        return valueMapper.map(result)
    }

    func add(_ value: Intention) {
        list.append(value)
    }
    func addNil() {
        list.append(NilIntention())
    }
}

public class ValueIntention: Intention {
    private var value: Intention? = nil

    func set(_ intention: Intention) {
        self.value = intention
    }
    func setNil() {
        self.value = NilIntention()
    }

    public func result<R>(_ valueMapper: any ValueMapper<R>) throws -> R {
        guard let value else {
            throw IntentionError.emptyIntention
        }
        return try value.result(valueMapper)
    }
}

class NilIntention: Intention {
    func result<R>(_ valueMapper: any ValueMapper<R>) throws -> R {
        return valueMapper.mapNil()
    }
}

class MapIntention: Intention {
    private let path: [any CodingKey]

    private var map: [String: Intention] = [:]

    init(path: [any CodingKey]) {
        self.path = path
    }

    func result<R>(_ valueMapper: any ValueMapper<R>) throws -> R {
        let result = try map.mapValues { try $0.result(valueMapper) }
        return valueMapper.map(result)
    }

    func set(_ key: CodingKey, _ value: Intention) {
        map[key.stringValue] = value
    }
    func setNil(_ key: CodingKey) {
        map[key.stringValue] = NilIntention()
    }
}
