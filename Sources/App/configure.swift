import Vapor
import VaporUtils

private let MINUTE: TimeInterval = 60
private let HOUR = 60 * MINUTE
private let DAY = 24 * HOUR

public func configure(_ app: Application) async throws {

  app.http.server.configuration.port = 3000
  app.middleware.use(RepoErrorMiddleware())

  app.poolsConfig = PoolsConfig(
    accessTokenExpirationTime: 15 * MINUTE,
    refreshTokenExpirationTime: 7 * DAY,
    rootPoolKid: "_master",
    rootPoolAccessTokenExpirationTime: 5 * MINUTE,
    rootPoolRefreshTokenExpirationTime: 15 * MINUTE
  )

  app.mongoNames = MongoNames(
    users: "auth_users",
    sessions: "auth_sessions",
    pools: "auth_pools",
    userPools: "auth_user_pools"
  )

  let prefix = try app.environmentShortName

  app.dynamoNames = DynamoNames(
    users: "\(prefix)_auth_user",
    userEmailMethod: "\(prefix)_auth_user_email_method",
    sessions: "\(prefix)_auth_session",
    pools: "\(prefix)_auth_pool"
  )

  let appUtils = AppUtils(app)
  try appUtils.configureCors()
  appUtils.setCompanyStandardJSONEncoderDecoder()

  try await app.initializeDynamo()
  try await app.configureMongo()
  try await app.loadKeys()

  try await app.setMasterPoolKey()

  // register routes
  try routes(app)
}
