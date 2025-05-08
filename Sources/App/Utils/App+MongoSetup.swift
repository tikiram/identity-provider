import AuthCore
import MongoAuth
import Utils
import Vapor

extension Application {
  func getMongoNames() throws -> MongoNames {
    guard let mongoNames = self.mongoNames else {
      throw RuntimeError("MongoNames not defined")
    }
    return mongoNames
  }
}

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

extension Application {
  func loadMongoPoolKeys() async throws {
    let mongoNames = try getMongoNames()

    let poolRepo = MongoPoolRepo(self.mongo, mongoNames.pools)
    let poolService = PoolService(poolRepo)
    let pools = try await poolService.getAll()

    // TODO: should load keys from the database rather than checking the env file

    for pool in pools {
      print("- key: \(pool.id) loaded")
      try await self.setJWTKeyFromEnv(name: "POOL_\(pool.id)", kid: pool.id)
    }

  }
}
