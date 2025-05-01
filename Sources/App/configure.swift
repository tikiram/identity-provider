import JWT
import MongoAuth
import MongoKitten
import SharedBackend
import Vapor

public func configure(_ app: Application) async throws {

  app.http.server.configuration.port = 3000
  //  app.middleware.use(RepoErrorMiddleware())

  app.masterPoolConfig = MasterPoolConfig(
    accessTokenExpirationTime: 60 * 5,
    refreshTokenExpirationTime: 60 * 15
  )

  app.mongoNames = MongoNames(users: "b_users", sessions: "b_sessions")

  let appUtils = AppUtils(app)
  try appUtils.configureCors()
  appUtils.setCompanyStandardJSONEncoderDecoder()

  try await app.configureMongo()
  try await app.setMasterPoolKey()

  // TODO: load more keys

  // register routes
  try routes(app)
}

extension Application {
  func setMasterPoolKey() async throws {
    guard let oneLinePrivateKeyString = Environment.get("MASTER_POOL_PRIVATE_KEY") else {
      throw RuntimeError("MASTER_POOL_PRIVATE_KEY not defined")
    }
    let privateKeyString = oneLinePrivateKeyString.replacingOccurrences(of: "\\n", with: "\n")

    // ECDSA - es256
    let privateKey = try ES256PrivateKey(pem: privateKeyString)

    await self.jwt.keys.add(ecdsa: privateKey, kid: "master")
  }
}

extension Application {
  func configureMongo() async throws {
    guard let MONGO_DB = Environment.get("MONGO_DB") else {
      throw RuntimeError("MONGO_DB not defined")
    }

    try await self.initializeMongoDB(MONGO_DB)

    guard let mongoNames = self.mongoNames else {
      throw RuntimeError("MongoNames not defined")
    }

    let manager = MongoAuthManager(self.mongo)
    try await manager.configureUsers(mongoNames.users)
    try await manager.configureSession(mongoNames.sessions)
  }
}
