import AuthCore
import JWTKit
import MongoAuth
import SharedBackend
import Vapor

extension Request {

  var simpleHasher: SimpleHasher {
    return AppSimpleHasher()
  }

  // JWT key has to be already defined before calling this method
  func bAuth(
    _ poolId: String,
    _ accessTokenExpirationTime: TimeInterval,
    _ refreshTokenExpirationTime: TimeInterval
  ) throws -> Auth {
    let mongoNames = try self.getMongoNames()

    let userRepo = MongoUserRepo(self.mongo, mongoNames.users, poolId)
    let userService = UserService(userRepo, self.password.async)

    let sessionRepo = MongoSessionRepo(self.mongo, mongoNames.sessions, self.simpleHasher)

    let tokenManager = AppTokenManager(
      self.jwt,
      poolId,
      accessTokenExpirationTime,
      refreshTokenExpirationTime
    )
    let sessionService = SessionService(sessionRepo, tokenManager)

    return Auth(userService, sessionService)
  }

  func bAuth() throws -> Auth {

    if self.poolId == "master" {
      guard let config = self.application.masterPoolConfig else {
        throw RuntimeError("Missing master pool configuration")
      }

      return try self.bAuth(
        "master",
        config.accessTokenExpirationTime,
        config.refreshTokenExpirationTime
      )
    }

    // TODO: get values from loaded pools
    throw RuntimeError("Pools not loaded")
  }

}
