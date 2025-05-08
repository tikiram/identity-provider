import AuthCore
import JWT
import Vapor

// static let accessTokenExpirationTime: TimeInterval = 60 * 60  // 1h
// static let refreshTokenExpirationTime: TimeInterval = 60 * 60 * 24  // 1d

struct AppTokenPayload: JWTPayload, Authenticatable, Content {
  enum CodingKeys: String, CodingKey {
    case subject = "sub"
    case expiration = "exp"
  }

  let subject: SubjectClaim
  let expiration: ExpirationClaim

  var userId: String {
    return subject.value
  }

  /// duration: seconds
  init(userId: String, duration: TimeInterval) {
    subject = SubjectClaim(value: userId)
    expiration = ExpirationClaim(value: Date().addingTimeInterval(duration))
  }

  func verify(using algorithm: some JWTAlgorithm) async throws {
    try self.expiration.verifyNotExpired()
  }
}

struct AppRefreshTokenPayload: JWTPayload, Authenticatable, Content, RefreshTokenPayload {

  enum CodingKeys: String, CodingKey {
    case subject = "sub"
    case expiration = "exp"
    case sessionId = "sid"
  }

  let subject: SubjectClaim
  let expiration: ExpirationClaim
  let sessionId: String

  var userId: String {
    return subject.value
  }

  init(userId: String, duration: TimeInterval, sessionId: String) {
    subject = SubjectClaim(value: userId)
    expiration = ExpirationClaim(value: Date().addingTimeInterval(duration))
    self.sessionId = sessionId
  }

  func verify(using algorithm: some JWTAlgorithm) async throws {
    try self.expiration.verifyNotExpired()
  }
}
