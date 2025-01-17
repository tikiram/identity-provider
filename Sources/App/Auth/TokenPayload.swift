import JWT
import Vapor

struct TokenPayload: JWTPayload, Authenticatable, Content {
  enum CodingKeys: String, CodingKey {
    case subject = "sub"
    case expiration = "exp"
  }

  let subject: SubjectClaim
  let expiration: ExpirationClaim

  var userId: String {
    return subject.value
  }

  init(userId: String, duration: TimeInterval) {
    subject = SubjectClaim(value: userId)
    expiration = ExpirationClaim(value: Date().addingTimeInterval(duration))
  }

  func verify(using _: JWTKit.JWTSigner) throws {
    try expiration.verifyNotExpired()
  }
}

struct RefreshTokenPayload: JWTPayload, Authenticatable, Content {
  enum CodingKeys: String, CodingKey {
    case subject = "sub"
    case expiration = "exp"
    case sessionSubId = "sid"
  }

  let subject: SubjectClaim
  let expiration: ExpirationClaim
  let sessionSubId: String

  var userId: String {
    return subject.value
  }

  init(userId: String, duration: TimeInterval, sessionSubId: String) {
    subject = SubjectClaim(value: userId)
    expiration = ExpirationClaim(value: Date().addingTimeInterval(duration))
    self.sessionSubId = sessionSubId
  }

  func verify(using _: JWTKit.JWTSigner) throws {
    try expiration.verifyNotExpired()
  }
}
