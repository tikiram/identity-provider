import Vapor

struct MongoNames {
  let users: String
  let sessions: String
}

private struct MongoNamesKey: StorageKey {
  typealias Value = MongoNames
}

extension Application {
  var mongoNames: MongoNames? {
    get {
      storage[MongoNamesKey.self]
    }
    set {
      storage[MongoNamesKey.self] = newValue
    }
  }
}
