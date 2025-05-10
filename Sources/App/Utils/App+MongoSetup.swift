import AuthCore
import MongoAuth
import Utils
import Vapor

extension Application {
  func configureMongo() async throws {

    guard let MONGO_DB = Environment.get("MONGO_DB") else {
      throw RuntimeError("MONGO_DB not defined")
    }

    try await self.initializeMongoDB(MONGO_DB)

    let mongoNames = try getMongoNames()

    let manager = MongoAuthManager(self.mongo)
    try await manager.configureUsers(mongoNames.users)
    try await manager.configureSession(mongoNames.sessions)
    try await manager.configureUserPool(mongoNames.pools, mongoNames.userPools)
  }
}

