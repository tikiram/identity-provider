import Fluent
import PostgresNIO
import Vapor

struct Tokens {
  let accessToken: String
  let refreshToken: String
}

enum AuthError: Error {
  case notValidToken
  case emailAlreadyUsed
  case invalidCredentials
}

class Auth {
  static let accessTokenExpirationTime: TimeInterval = 60 * 60  // 1h
  static let refreshTokenExpirationTime: TimeInterval = 60 * 60 * 24  // 1d

  private let database: Database
  private let jwt: Request.JWT

  init(database: Database, jwt: Request.JWT) {
    self.database = database
    self.jwt = jwt
  }

  func register(email: String, password: String) async throws -> Tokens {
    let user = try User(
      email: email,
      passwordHash: Bcrypt.hash(password)
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

    let sameHash = try Bcrypt.verify(password, created: user.passwordHash)

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

  func getNewAccessToken(refreshToken: String) async throws -> String {
    let foundSession = try await Session.query(on: database)
      .with(\.$user)
      .filter(\.$refreshToken == refreshToken)
      .first()

    // TODO: validate token is not expired

    guard let session = foundSession else {
      throw AuthError.notValidToken
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

  private func storeRefreshToken(
    _ refreshToken: String,
    userId: User.IDValue
  ) async throws {
    let session = Session(refreshToken: refreshToken, userID: userId)
    try await session.save(on: database)
  }
}
