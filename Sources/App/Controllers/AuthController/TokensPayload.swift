
import Vapor

struct TokensPayload: Content {
  let grandType: String
}

struct PasswordGrandTypePayload: Content {
  let username: String
  let password: String
}

struct RefreshTokenGrandTypePayload: Content {
  let refreshToken: String
}
