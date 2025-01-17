import AWSDynamoDB
import JWTKit
import Vapor

struct Tokens {
  let accessToken: String
  let refreshToken: String
}

enum AuthError: Error {
  case jwtError(JWTError)
  case tokenNotFound
  case notValidToken  // TODO: remove this
  case invalidToken
  case emailAlreadyUsed
  case userHasNoPassword
  case invalidCredentials
}

class Auth {
  static let accessTokenExpirationTime: TimeInterval = 60 * 60  // 1h
  static let refreshTokenExpirationTime: TimeInterval = 60 * 60 * 24  // 1d

  private let jwt: Request.JWT
  private let emailNotifications: EmailNotifications
  private let logger: Logger

  private let sessionRepo: SessionRepo
  private let userRepo: UserRepo

  init(_ req: Request) async throws {
    self.jwt = req.jwt
    self.emailNotifications = try req.emailNotifications
    self.logger = req.logger

    self.sessionRepo = try await req.sessionRepo
    self.userRepo = try await req.userRepo
  }

  func register(email: String, password: String?) async throws -> Tokens {
    do {
      let user = try await userRepo.create(email: email, password: password!)
      return try await createTokensForNewSession(userId: user.id)
    } catch let error as TransactionCanceledException where hasConditionalCheckFailed(error) {
      throw AuthError.emailAlreadyUsed
    }
  }

  func authenticate(email: String, password: String) async throws -> Tokens {

    let userEmailMethod = try await userRepo.getEmailMethod(email)

    guard let userEmailMethod else {
      throw AuthError.invalidCredentials
    }

    let sameHash = try Bcrypt.verify(password, created: userEmailMethod.passwordHash)

    guard sameHash else {
      // TODO: block user for certain amount of time after 3 attempts
      throw AuthError.invalidCredentials
    }

    return try await createTokensForNewSession(userId: userEmailMethod.userId)
  }

  private func createTokensForNewSession(userId: String) async throws -> Tokens {
    let accessToken = try createAccessToken(userId: userId)

    let sessionSubId = UUID().uuidString
    let refreshToken = try createRefreshToken(userId: userId, sessionSubId: sessionSubId)

    try await self.sessionRepo.save(
      userId: userId, sessionSubId: sessionSubId, refreshToken: refreshToken)

    return Tokens(accessToken: accessToken, refreshToken: refreshToken)
  }

  private func rotateTokensWithPayload(_ payload: RefreshTokenPayload) async throws -> Tokens {
    let accessToken = try createAccessToken(userId: payload.userId)
    let refreshToken = try createRefreshToken(
      userId: payload.userId, sessionSubId: payload.sessionSubId)

    try await self.sessionRepo.update(
      userId: payload.userId, sessionSubId: payload.sessionSubId, refreshToken: refreshToken)

    return Tokens(accessToken: accessToken, refreshToken: refreshToken)
  }

  func logout(_ refreshToken: String) async throws {
    let payload = try await getRefreshTokenPayloadRelatedToValidSession(refreshToken)
    try await self.sessionRepo.delete(userId: payload.userId, sessionSubId: payload.sessionSubId)
  }

  func rotateTokenUsingRefreshToken(_ refreshToken: String) async throws -> Tokens {

    // TODO: detect stolen refreshToken, a token should only be re-used
    // after access-token expiration time

    // TODO: check these suggestions
    // https://stackoverflow.com/questions/59511628/is-it-secure-to-store-a-refresh-token-in-the-database-to-issue-new-access-toke

    let payload = try await getRefreshTokenPayloadRelatedToValidSession(refreshToken)
    let tokens = try await rotateTokensWithPayload(payload)
    return tokens
  }

  func getRefreshTokenPayloadRelatedToValidSession(_ refreshToken: String) async throws
    -> RefreshTokenPayload
  {
    let payload = try jwt.verify(refreshToken, as: RefreshTokenPayload.self)

    let isValid = try await sessionRepo.getIsValid(
      userId: payload.userId, sessionSubId: payload.sessionSubId, refreshToken: refreshToken)

    guard isValid else {
      throw AuthError.invalidToken
    }
    return payload
  }

  private func createAccessToken(userId: String) throws -> String {
    let payload = TokenPayload(
      userId: userId,
      duration: Self.accessTokenExpirationTime
    )
    let token = try jwt.sign(payload)
    return token
  }

  private func createRefreshToken(userId: String, sessionSubId: String) throws -> String {
    let refreshPayload = RefreshTokenPayload(
      userId: userId,
      duration: Self.refreshTokenExpirationTime,
      sessionSubId: sessionSubId
    )
    let refreshToken = try jwt.sign(refreshPayload, kid: "refresh")
    return refreshToken
  }

  func sendResetCode(email: String) async throws {

    //    let user = try await User.query(on: database)
    //      .filter(\.$email == email.lowercased())
    //      .first()
    //
    //    guard let user else {
    //      // Visitor has no way to check the email is associated to an user
    //      self.logger.info("Email not associated to an user")
    //      return
    //    }
    //
    //    self.logger.info("Email associated to an user")
    //
    //    let randomInt = Int.random(in: 0..<999999)
    //    let code = String(format: "%06d", randomInt)
    //
    //    let resetAttempt = try ResetAttempt(
    //      userID: user.requireID(), email: email.lowercased(), code: code)
    //    try await resetAttempt.save(on: self.database)
    //
    //    try await self.emailNotifications.sendRecoveryCode(to: email, code: code)
  }

}
