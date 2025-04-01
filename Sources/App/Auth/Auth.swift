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
  // TODO: get these values from env configuration
  static let accessTokenExpirationTime: TimeInterval = 60 * 60  // 1h
  static let refreshTokenExpirationTime: TimeInterval = 60 * 60 * 24  // 1d

  private let jwt: Request.JWT
  private let emailNotifications: EmailNotifications
  private let logger: Logger

  private let sessionRepo: SessionRepo
  
  private let userRepo: UserRepo
  private let appPasswordHasher: AppPasswordHasher

  init(
    _ req: Request,
    _ userRepo: UserRepo,
    _ appPasswordHasher: AppPasswordHasher
  ) async throws {
    self.jwt = req.jwt
    self.emailNotifications = try req.emailNotifications
    self.logger = req.logger

    self.sessionRepo = try await req.sessionRepo
    
    self.userRepo = userRepo
    self.appPasswordHasher = appPasswordHasher
  }

  func register(email: String, password: String?) async throws -> Tokens {
    let user = try await userRepo.create(email: email, password: password!)
    return try await createTokensForNewSession(userId: user.id)
  }

  func authenticate(email: String, password: String) async throws -> Tokens {

    let userEmailMethod = try await userRepo.getEmailMethod(email)

    guard let userEmailMethod else {
      throw AuthError.invalidCredentials
    }
    
    let sameHash = try await appPasswordHasher.verify(password, userEmailMethod.passwordHash)

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

  public func rotateTokens(_ refreshToken: String) async throws -> Tokens {
    // TODO: detect stolen refreshToken

    // https://stackoverflow.com/questions/59511628/is-it-secure-to-store-a-refresh-token-in-the-database-to-issue-new-access-toke

    let payload = try jwt.verify(refreshToken, as: RefreshTokenPayload.self)

    let accessToken = try createAccessToken(userId: payload.userId)
    let newRefreshToken = try createRefreshToken(
      userId: payload.userId, sessionSubId: payload.sessionSubId)

    do {
      try await self.sessionRepo.update(
        userId: payload.userId,
        sessionSubId: payload.sessionSubId,
        newRefreshToken: newRefreshToken,
        previousRefreshToken: refreshToken
      )
      return Tokens(accessToken: accessToken, refreshToken: newRefreshToken)
    } catch let error as ConditionalCheckFailedException {
      // TODO: append error information to AuthError.invalidToken
      throw AuthError.invalidToken
    }
  }

  func logout(_ refreshToken: String) async throws {
    let payload = try jwt.verify(refreshToken, as: RefreshTokenPayload.self)

    do {
      try await self.sessionRepo.delete(
        userId: payload.userId, sessionSubId: payload.sessionSubId, refreshToken: refreshToken)
    } catch let error as ConditionalCheckFailedException {
      // TODO: append error information to AuthError.invalidToken
      throw AuthError.invalidToken
    }
  }

  private func createAccessToken(userId: String) throws -> String {
    let payload = TokenPayload(
      userId: userId,
      duration: Self.accessTokenExpirationTime
    )
    let token = try jwt.sign(payload, kid: "private")
    return token
  }

  private func createRefreshToken(userId: String, sessionSubId: String) throws -> String {
    let refreshPayload = RefreshTokenPayload(
      userId: userId,
      duration: Self.refreshTokenExpirationTime,
      sessionSubId: sessionSubId
    )
    let refreshToken = try jwt.sign(refreshPayload, kid: "private")
    return refreshToken
  }

  func sendResetCode(email: String) async throws {

    let userEmailMethod = try await userRepo.getEmailMethod(email)

    guard let userEmailMethod else {
      logger.info("Email not associated to an user", metadata: ["email": "\(email)"])
      return
    }
    let code = getRandomIntString(digits: 6)
    //
    //    let resetAttempt = try ResetAttempt(
    //      userID: user.requireID(), email: email.lowercased(), code: code)
    //    try await resetAttempt.save(on: self.database)
    //
    //    try await self.emailNotifications.sendRecoveryCode(to: email, code: code)
  }

}

func getRandomInt(maxDigits: Int) -> Int {
  let upperLimit = Int(pow(10.0, Double(maxDigits))) - 1
  return Int.random(in: 0...upperLimit)
}

func getRandomIntString(digits: Int) -> String {
  let randomInt = getRandomInt(maxDigits: digits)
  return String(randomInt).padding(toLength: digits, withPad: "0", startingAt: 0)
}
