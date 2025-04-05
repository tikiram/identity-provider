import Vapor

struct TokensResponse: Content {
  let accessToken: String
  let refreshToken: String?
  let expiresIn: Double
  let refreshTokenExpiresIn: Double

  init(tokens: Tokens, expiresIn: Double, refreshTokenExpiresIn: Double) {
    accessToken = tokens.accessToken
    refreshToken = tokens.refreshToken
    self.expiresIn = expiresIn
    self.refreshTokenExpiresIn = refreshTokenExpiresIn
  }

  init(accessToken: String, expiresIn: Double, refreshTokenExpiresIn: Double) {
    self.accessToken = accessToken
    self.refreshToken = nil
    self.expiresIn = expiresIn
    self.refreshTokenExpiresIn = refreshTokenExpiresIn
  }
}
