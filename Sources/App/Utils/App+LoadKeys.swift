import AuthCore
import DynamoAuth
import MongoAuth
import Vapor

extension Application {

  private func loadKeysFromService(poolRepo: any PoolRepo) async throws {
    let poolService = PoolService(poolRepo)
    let pools = try await poolService.getAll()

    // TODO: should load keys from the database rather than checking the env file

    for pool in pools {
      print("- key: \(pool.id) loaded")
      try await self.setJWTKeyFromEnv(name: "POOL_\(pool.id)", kid: pool.id)
    }
  }

  private func loadMongoPoolKeys() async throws {
    let mongoNames = try getMongoNames()
    let poolRepo = MongoPoolRepo(self.mongo, mongoNames.pools)
    try await loadKeysFromService(poolRepo: poolRepo)
  }

  private func loadDynamoPoolKeys() async throws {
    let dynamoNames = try getDynamoNames()
    let poolRepo = DynamoPoolRepo(self.dynamo, dynamoNames.pools)
    try await loadKeysFromService(poolRepo: poolRepo)
  }

  func loadKeys() async throws {
    print("Mongo keys:")
    try await loadMongoPoolKeys()
    print("dynamo keys:")
    try await loadDynamoPoolKeys()
  }
}
