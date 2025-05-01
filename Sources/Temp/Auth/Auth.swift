import Foundation
import JWTKit
import Vapor

struct Tokens {
  let accessToken: String
  let refreshToken: String
}

enum AuthError: Error {
  case jwtError(JWTError)
  case tokenNotFound
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
    _ sessionRepo: SessionRepo,
    _ appPasswordHasher: AppPasswordHasher
  ) async throws {
    self.jwt = req.jwt
    self.emailNotifications = try req.emailNotifications
    self.logger = req.logger

    self.sessionRepo = sessionRepo

    self.userRepo = userRepo
    self.appPasswordHasher = appPasswordHasher
  }

  func register(email: String, password: String?) async throws -> Tokens {
    let user = try await userRepo.create(email: email, password: password!)
    return try await createTokensForNewSession(user: user)
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

    let user = try await userRepo.getUser(userId: userEmailMethod.userId)

    return try await createTokensForNewSession(user: user)
  }

  private func createTokensForNewSession(user: User) async throws -> Tokens {
    let accessToken = try await createAccessToken(userId: user.id, roles: user.roles)

    let sessionSubId = UUID().uuidString
    let refreshToken = try await createRefreshToken(
      userId: user.id,
      roles: user.roles,
      sessionSubId: sessionSubId
    )

    try await self.sessionRepo.save(
      userId: user.id,
      sessionSubId: sessionSubId,
      refreshToken: refreshToken
    )

    return Tokens(accessToken: accessToken, refreshToken: refreshToken)
  }

  public func rotateTokens(_ refreshToken: String) async throws -> Tokens {
    // TODO: detect stolen refreshToken

    // https://stackoverflow.com/questions/59511628/is-it-secure-to-store-a-refresh-token-in-the-database-to-issue-new-access-toke

    let payload = try await jwt.verify(refreshToken, as: RefreshTokenPayload.self)

    let accessToken = try await createAccessToken(userId: payload.userId, roles: payload.roles)
    let newRefreshToken = try await createRefreshToken(
      userId: payload.userId,
      roles: payload.roles,
      sessionSubId: payload.sessionSubId
    )

    try await self.sessionRepo.update(
      userId: payload.userId,
      sessionSubId: payload.sessionSubId,
      newRefreshToken: newRefreshToken,
      previousRefreshToken: refreshToken
    )
    return Tokens(accessToken: accessToken, refreshToken: newRefreshToken)
  }

  func logout(_ refreshToken: String) async throws {
    let payload = try await jwt.verify(refreshToken, as: RefreshTokenPayload.self)
    try await self.sessionRepo.invalidate(
      userId: payload.userId,
      sessionSubId: payload.sessionSubId,
      refreshToken: refreshToken
    )
  }

  private func createAccessToken(userId: String, roles: [String]) async throws -> String {
    let payload = TokenPayload(
      userId: userId,
      roles: roles,
      duration: Self.accessTokenExpirationTime
    )
    let token = try await jwt.sign(payload, kid: "private")
    return token
  }

  private func createRefreshToken(userId: String, roles: [String], sessionSubId: String)
    async throws -> String
  {
    let refreshPayload = RefreshTokenPayload(
      userId: userId,
      roles: roles,
      duration: Self.refreshTokenExpirationTime,
      sessionSubId: sessionSubId
    )
    let refreshToken = try await jwt.sign(refreshPayload, kid: "private")
    return refreshToken
  }

  func sendResetCode(email: String) async throws {

    //    let userEmailMethod = try await userRepo.getEmailMethod(email)
    //
    //    guard let userEmailMethod else {
    //      logger.info("Email not associated to an user", metadata: ["email": "\(email)"])
    //      return
    //    }
    //    let code = getRandomIntString(digits: 6)
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
