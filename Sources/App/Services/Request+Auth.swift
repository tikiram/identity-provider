import AuthCore
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

  // JWT key has to be already defined before calling this method
  func bAuth(
    _ poolId: String?,
    _ accessTokenExpirationTime: TimeInterval,
    _ refreshTokenExpirationTime: TimeInterval
  ) throws -> Auth {
    let mongoNames = try self.getMongoNames()

    let userRepo = MongoUserRepo(self.mongo, mongoNames.users, poolId)
    let userService = UserService(userRepo, self.password.async)

    let sessionRepo = MongoSessionRepo(self.mongo, mongoNames.sessions)

    let config = try self.application.getPoolConfig()

    let tokenManager = AppTokenManager(
      jwt: self.jwt,
      kid: poolId ?? config.rootPoolKid,
      accessTokenExpirationTime,
      refreshTokenExpirationTime
    )
    let sessionService = SessionService(sessionRepo, tokenManager, self.simpleHasher)

    return Auth(userService, sessionService)
  }

  func bAuth() throws -> Auth {
    let config = try self.application.getPoolConfig()

    return try self.bAuth(
      self.poolId,
      self.poolId == nil
        ? config.rootPoolAccessTokenExpirationTime : config.accessTokenExpirationTime,
      self.poolId == nil
        ? config.rootPoolRefreshTokenExpirationTime : config.refreshTokenExpirationTime
    )
  }

}
