import SharedBackend
import Vapor

private let MINUTE: TimeInterval = 60
private let HOUR = 60 * MINUTE
private let DAY = 24 * HOUR

public func configure(_ app: Application) async throws {

  app.http.server.configuration.port = 3000
  //  app.middleware.use(RepoErrorMiddleware())

  app.poolsConfig = PoolsConfig(
    accessTokenExpirationTime: 15 * MINUTE,
    refreshTokenExpirationTime: 7 * DAY,
    rootPoolKid: "_master",
    rootPoolAccessTokenExpirationTime: 5 * MINUTE,
    rootPoolRefreshTokenExpirationTime: 15 * MINUTE
  )

  app.mongoNames = MongoNames(
    users: "b_users",
    sessions: "b_sessions",
    pools: "b_pools",
    userPools: "b_user_pools",
  )

  let appUtils = AppUtils(app)
  try appUtils.configureCors()
  appUtils.setCompanyStandardJSONEncoderDecoder()

  try await app.configureMongo()
  try await app.loadMongoPoolKeys()

  try await app.setMasterPoolKey()

  // register routes
  try routes(app)
}
