import AuthCore
import DynamoAuth
import JWTKit
import MongoAuth
import Utils
import Vapor

extension Request {

  var simpleHasher: SimpleHasher {
    switch self.application.environment {
    case .development:
      return DevSimpleHasher()
    default:
      return AppSimpleHasher()
    }
  }

  // JWT keys have to be already defined before calling this method

  func buildAuth(
    _ userRepo: UserRepo,
    _ sessionRepo: SessionRepo,
  ) throws -> Auth {

    let config = try self.application.getPoolConfig()

    let accessTokenExpirationTime =
      self.poolId == nil
      ? config.rootPoolAccessTokenExpirationTime : config.accessTokenExpirationTime

    let refreshTokenExpirationTime =
      self.poolId == nil
      ? config.rootPoolRefreshTokenExpirationTime : config.refreshTokenExpirationTime

    let userService = UserService(userRepo, self.password.async)

    let tokenManager = AppTokenManager(
      jwt: self.jwt,
      kid: poolId ?? config.rootPoolKid,
      accessTokenExpirationTime,
      refreshTokenExpirationTime
    )
    let sessionService = SessionService(sessionRepo, tokenManager, self.simpleHasher)

    return Auth(userService, sessionService)
  }

  /// Mostly just Mongo but it can use DynamoDB too
  func bAuth() throws -> Auth {
    let mongoNames = try self.application.getMongoNames()
    let userRepo = MongoUserRepo(self.mongo, mongoNames.users, self.poolId)
    let sessionRepo = MongoSessionRepo(self.mongo, mongoNames.sessions)
    return try self.buildAuth(userRepo, sessionRepo)
  }

  /// Just DynamoDB
  func cAuth() throws -> Auth {
    let dynamoNames = try self.application.getDynamoNames()
    let userRepo = DynamoUserRepo(
      self.application.dynamo, dynamoNames.users, dynamoNames.userEmailMethod, self.poolId)
    let sessionRepo = DynamoSessionRepo(self.application.dynamo, dynamoNames.sessions)
    return try self.buildAuth(userRepo, sessionRepo)
  }

}
