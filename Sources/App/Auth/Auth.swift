import Fluent
import JWTKit
import Vapor

struct Tokens {
  let accessToken: String
  let refreshToken: String
}

enum AuthError: Error {
  case jwtError(JWTError)
  case tokenNotFound
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

  private let sessionRepo: SessionRepo
  private let userRepo: UserRepo

  init(_ req: Request) async throws {
    self.database = req.db
    self.jwt = req.jwt
    self.emailNotifications = try req.emailNotifications
    self.logger = req.logger
    self.sessionRepo = try await SessionRepo(req.dynamoDBClient, tableNamePrefix: "dev_")
    self.userRepo = try await UserRepo(req.dynamoDBClient, tableNamePrefix: "dev_")
  }

  func register(email: String, password: String?) async throws -> Tokens {

    //    do {
    let user = try await userRepo.create(email: email, password: password!)
    
    // TODO: add this validation for DynamoDB
    //    } catch let error as PSQLError where error.isConstraintFailure {
    //      throw AuthError.emailAlreadyUsed
    //    }

    return try await createTokens(userId: user.id)
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

    return try await createTokens(userId: userEmailMethod.userId)
  }

  private func createTokens(userId: String) async throws -> Tokens {
    let accessToken = try createAccessToken(userId: userId)
    let refreshToken = try createRefreshToken(userId: userId)

    try await self.sessionRepo.save(userId: userId, refreshToken: refreshToken)

    return Tokens(accessToken: accessToken, refreshToken: refreshToken)
  }

  func logout(refreshToken: String) async throws {
    let payload = try jwt.verify(refreshToken, as: TokenPayload.self)
    try await self.sessionRepo.softDelete(
      userId: payload.userId, refreshToken: refreshToken)
  }

  func getNewAccessToken(refreshToken: String) async throws -> String {

    // TODO: detect stolen refreshToken, a token should only be re-used
    // after access-token expiration time

    // TODO: check these suggestions
    // https://stackoverflow.com/questions/59511628/is-it-secure-to-store-a-refresh-token-in-the-database-to-issue-new-access-toke

    do {
      let payload = try jwt.verify(refreshToken, as: TokenPayload.self)

      let isValid = try await sessionRepo.getIsValid(
        userId: payload.userId, refreshToken: refreshToken)

      guard isValid else {
        throw AuthError.tokenNotFound
      }

      // TODO: create access token based on the content of the refreshToken
      let accessToken = try createAccessToken(userId: payload.userId)

      return accessToken
    } catch let error as JWTError {
      throw AuthError.jwtError(error)
    }
  }

  private func createAccessToken(userId: String) throws -> String {
    let payload = TokenPayload(
      userId: userId,
      duration: Self.accessTokenExpirationTime
    )
    let token = try jwt.sign(payload)
    return token
  }

  private func createRefreshToken(userId: String) throws -> String {
    let refreshPayload = TokenPayload(
      userId: userId,
      duration: Self.refreshTokenExpirationTime
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
