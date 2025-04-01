import Vapor

extension Request {
  var authFactory: AuthFactory {
    return AuthFactory(
      self.mongoUserRepoFactory,
      self.appPasswordHasher
    )
  }
}
