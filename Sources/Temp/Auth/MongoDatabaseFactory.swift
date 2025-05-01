import MongoKitten
// TODO: remove vapor dependency
import Vapor

class MongoDatabaseFactory {  
  private var mongoDatabases: [String: MongoDatabase]?
  
  init(mongoDatabases: [String: MongoDatabase]?) {
    self.mongoDatabases = mongoDatabases
  }
  
  func getMongoDatabase(_ clientId: String) async throws -> MongoDatabase {
    guard var databases = mongoDatabases else {
      throw MongoDatabaseFactoryError.mongoDatabasesDictionaryNotSet
    }

    if let database = databases[clientId] {
      // Note: instance is reused to skip trigger a new connection
      return database
    }

    guard let connectionString = Environment.get("MONGO_DB_\(clientId)") else {
      throw MongoDatabaseFactoryError.connectionStringNotFound
    }

    let mongoDatabase = try await MongoDatabase.connect(to: connectionString)

    databases[clientId] = mongoDatabase

    return mongoDatabase
  }
}

