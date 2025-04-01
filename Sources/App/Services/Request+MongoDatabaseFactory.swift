import MongoKitten
import Vapor

private struct MongoReposKey: StorageKey {
  typealias Value = [String: MongoDatabase]
}

extension Application {
  var mongoDatabases: [String: MongoDatabase]? {
    get {
      storage[MongoReposKey.self]
    }
    set {
      storage[MongoReposKey.self] = newValue
    }
  }
}

enum MongoDatabaseFactoryError: Error {
  case mongoDatabasesDictionaryNotSet
  case connectionStringNotFound
}


extension Request {  
  var mongoDatabaseFactory: MongoDatabaseFactory {
    return MongoDatabaseFactory(mongoDatabases: application.mongoDatabases)
  }
}
