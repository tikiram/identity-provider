import Foundation

public protocol RefreshTokenPayload {
  var userId: String { get }
  var sessionId: String { get }
}

public struct TokenInfo {
  public let value: String
  public let expiresIn: TimeInterval

  public init(value: String, expiresIn: TimeInterval) {
    self.value = value
    self.expiresIn = expiresIn
  }
}

public struct Tokens {
  public let accessTokenInfo: TokenInfo
  public let refreshTokenInfo: TokenInfo

  public init(_ accessTokenInfo: TokenInfo, _ refreshTokenInfo: TokenInfo) {
    self.accessTokenInfo = accessTokenInfo
    self.refreshTokenInfo = refreshTokenInfo
  }
}

public protocol TokenManager {
  func buildTokens(_ user: User, sessionId: String) async throws -> Tokens
  func buildTokens(_ refreshToken: String) async throws -> Tokens
  func getPayload(_ refreshToken: String) async throws -> RefreshTokenPayload
}
