
import Vapor

struct TokensResponse: Content {
  let accessToken: String
  let refreshToken: String?
  let expiresIn: Double
  
  init(tokens: Tokens, expiresIn: Double) {
    accessToken = tokens.accessToken
    refreshToken = tokens.refreshToken
    self.expiresIn = expiresIn
  }
  
  init(accessToken: String, expiresIn: Double) {
    self.accessToken = accessToken
    self.refreshToken = nil
    self.expiresIn = expiresIn
  }
}
