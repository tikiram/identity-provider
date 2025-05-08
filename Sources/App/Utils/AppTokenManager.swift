import AuthCore
import JWTKit
import Vapor

final class AppTokenManager: TokenManager {

  private let jwt: Request.JWT
  private let kid: String
  private let accessTokenExpirationTime: TimeInterval
  private let refreshTokenExpirationTime: TimeInterval

  init(
    jwt: Request.JWT,
    kid: String,
    _ accessTokenExpirationTime: TimeInterval,
    _ refreshTokenExpirationTime: TimeInterval
  ) {
    self.jwt = jwt
    self.kid = kid
    self.accessTokenExpirationTime = accessTokenExpirationTime
    self.refreshTokenExpirationTime = refreshTokenExpirationTime
  }

  func buildTokens(_ user: any User, sessionId: String) async throws -> Tokens {
    let accessToken = try await getAccessToken(user.id)
    let refreshToken = try await getRefreshToken(user.id, sessionId)
    return Tokens(accessToken, refreshToken)
  }

  func buildTokens(_ refreshToken: String) async throws -> Tokens {
    let payload = try await jwt.verify(refreshToken, as: AppRefreshTokenPayload.self)
    let accessToken = try await getAccessToken(payload.userId)
    let refreshToken = try await getRefreshToken(payload.userId, payload.sessionId)
    return Tokens(accessToken, refreshToken)
  }

  private func getAccessToken(_ userId: String) async throws -> TokenInfo {
    let payload = AppTokenPayload(
      userId: userId,
      duration: self.accessTokenExpirationTime
    )
    let value = try await jwt.sign(payload, kid: JWKIdentifier(string: self.kid))

    return TokenInfo(value: value, expiresIn: self.accessTokenExpirationTime)
  }

  private func getRefreshToken(_ userId: String, _ sessionId: String)
    async throws -> TokenInfo
  {
    let refreshTokenPayload = AppRefreshTokenPayload(
      userId: userId,
      duration: self.refreshTokenExpirationTime,
      sessionId: sessionId
    )

    let value = try await jwt.sign(refreshTokenPayload, kid: JWKIdentifier(string: self.kid))

    return TokenInfo(value: value, expiresIn: self.refreshTokenExpirationTime)
  }

  func getPayload(_ refreshToken: String) async throws -> any RefreshTokenPayload {
    let payload = try await jwt.verify(refreshToken, as: AppRefreshTokenPayload.self)
    return payload
  }

}
