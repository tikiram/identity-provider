import Vapor
import Utils

struct MongoNames {
  let users: String
  let sessions: String
  let pools: String
  let userPools: String 
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

extension Application {
  func getMongoNames() throws -> MongoNames {
    guard let mongoNames = self.mongoNames else {
      throw RuntimeError("MongoNames not defined")
    }
    return mongoNames
  }
}