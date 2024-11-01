import Fluent
import JWTKit
import PostgresNIO
import Vapor

struct Tokens {
  let accessToken: String
  let refreshToken: String
}

enum AuthError: Error {
  case notValidToken
  case emailAlreadyUsed
  case userHasNoPassword
  case invalidCredentials
}

class Auth {
  static let accessTokenExpirationTime: TimeInterval = 60 * 60  // 1h
  static let refreshTokenExpirationTime: TimeInterval = 60 * 60 * 24  // 1d

  private let database: Database
  private let jwt: Request.JWT
  private let emailNotifications: EmailNotifications
  private let logger: Logger

  init(_ req: Request) throws {
    self.database = req.db
    self.jwt = req.jwt
    self.emailNotifications = try req.emailNotifications
    self.logger = req.logger
  }

  func register(email: String, password: String?) async throws -> Tokens {

    let user = User(
      email: email.lowercased(),
      passwordHash: try password.map { try Bcrypt.hash($0) }
    )

    do {
      try await user.save(on: database)
    } catch let error as PSQLError where error.isConstraintFailure {
      throw AuthError.emailAlreadyUsed
    }

    return try await createTokens(of: user)
  }

  func authenticate(email: String, password: String) async throws -> Tokens {
    let user = try await User.query(on: database)
      .filter(\.$email == email)
      .first()

    guard let user else {
      throw AuthError.invalidCredentials
    }

    guard let userPasswordHash = user.passwordHash else {
      throw AuthError.userHasNoPassword
    }

    let sameHash = try Bcrypt.verify(password, created: userPasswordHash)

    guard sameHash else {
      throw AuthError.invalidCredentials
    }

    return try await createTokens(of: user)
  }

  private func createTokens(of user: User) async throws -> Tokens {
    let accessToken = try createAccessToken(of: user)
    let refreshToken = try createRefreshToken(of: user)
    try await storeRefreshToken(refreshToken, userId: user.requireID())
    return Tokens(accessToken: accessToken, refreshToken: refreshToken)
  }

  private func storeRefreshToken(
    _ refreshToken: String,
    userId: User.IDValue
  ) async throws {
    let session = Session(refreshToken: refreshToken, userID: userId)
    try await session.save(on: database)
  }

  func logout(refreshToken: String) async throws {
    try await Session.query(on: database)
      .filter(\.$refreshToken == refreshToken)
      .delete()
  }

  func getNewAccessToken(refreshToken: String) async throws -> String {

    // TODO: check these suggestions
    // https://stackoverflow.com/questions/59511628/is-it-secure-to-store-a-refresh-token-in-the-database-to-issue-new-access-toke

    // TODO: check indexes on Session table

    let session = try await Session.query(on: database)
      .with(\.$user)
      .filter(\.$refreshToken == refreshToken)
      .first()

    guard let session else {
      throw AuthError.notValidToken
    }

    do {
      let _ = try jwt.verify(refreshToken, as: TokenPayload.self)
    } catch let error as JWTError {
      try await session.delete(on: database)
      throw error
    }

    let accessToken = try createAccessToken(of: session.user)

    return accessToken
  }

  private func createAccessToken(of user: User) throws -> String {
    let payload = TokenPayload(
      user: user,
      duration: Self.accessTokenExpirationTime
    )
    let token = try jwt.sign(payload)
    return token
  }

  private func createRefreshToken(of user: User) throws -> String {
    let refreshPayload = TokenPayload(
      user: user,
      duration: Self.refreshTokenExpirationTime
    )
    let refreshToken = try jwt.sign(refreshPayload, kid: "refresh")
    return refreshToken
  }

  func sendResetCode(email: String) async throws {

    let user = try await User.query(on: database)
      .filter(\.$email == email.lowercased())
      .first()

    guard let user else {
      // Visitor has no way to check the email is associated to an user
      self.logger.info("Email not associated to an user")
      return
    }

    self.logger.info("Email associated to an user")

    let randomInt = Int.random(in: 0..<999999)
    let code = String(format: "%06d", randomInt)

    let resetAttempt = try ResetAttempt(userID: user.requireID(), email: email.lowercased(), code: code)
    try await resetAttempt.save(on: self.database)

    try await self.emailNotifications.sendRecoveryCode(to: email, code: code)
  }

}
