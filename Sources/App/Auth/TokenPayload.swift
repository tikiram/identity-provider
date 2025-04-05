import JWT
import Vapor

struct TokenPayload: JWTPayload, Authenticatable, Content {
  enum CodingKeys: String, CodingKey {
    case subject = "sub"
    case expiration = "exp"
    case roles = "roles"
  }

  let subject: SubjectClaim
  let expiration: ExpirationClaim
  
  let roles: [String]

  var userId: String {
    return subject.value
  }

  init(userId: String, roles: [String], duration: TimeInterval) {
    subject = SubjectClaim(value: userId)
    expiration = ExpirationClaim(value: Date().addingTimeInterval(duration))
    self.roles = roles
  }

  func verify(using algorithm: some JWTAlgorithm) async throws {
    try self.expiration.verifyNotExpired()
  }
}

struct RefreshTokenPayload: JWTPayload, Authenticatable, Content {
  enum CodingKeys: String, CodingKey {
    case subject = "sub"
    case expiration = "exp"
    case sessionSubId = "sid"
    case roles = "roles"
  }

  let subject: SubjectClaim
  let expiration: ExpirationClaim
  let sessionSubId: String
  let roles: [String]

  var userId: String {
    return subject.value
  }

  init(userId: String, roles: [String], duration: TimeInterval, sessionSubId: String) {
    subject = SubjectClaim(value: userId)
    expiration = ExpirationClaim(value: Date().addingTimeInterval(duration))
    self.sessionSubId = sessionSubId
    self.roles = roles
  }

  func verify(using algorithm: some JWTAlgorithm) async throws {
    try self.expiration.verifyNotExpired()
  }
}
