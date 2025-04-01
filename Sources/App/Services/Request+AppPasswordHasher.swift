import Vapor

extension Request {
  var appPasswordHasher: AppPasswordHasher {
    return VaporAppPasswordHasher(self.password.async)
  }

}
