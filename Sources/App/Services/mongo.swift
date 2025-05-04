import MongoKitten
import Vapor

private struct MongoDBStorageKey: StorageKey {
  typealias Value = MongoDatabase
}

extension Application {
  public var mongo: MongoDatabase {
    get {
      storage[MongoDBStorageKey.self]!
    }
    set {
      storage[MongoDBStorageKey.self] = newValue
    }
  }

  public func initializeMongoDB(_ connectionString: String) async throws {
    self.mongo = try await MongoDatabase.connect(to: connectionString)
  }
}

extension Request {
  public var mongo: MongoDatabase {
    return application.mongo.adoptingLogMetadata([
      "request-id": .string(id)
    ])
  }
}
