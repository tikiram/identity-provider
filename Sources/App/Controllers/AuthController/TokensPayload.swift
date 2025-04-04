import Vapor

enum GrantType: String, Codable {
  case password
  case refreshToken = "refresh_token"
}

struct TokensPayload: Content, Validatable {
  let grantType: GrantType

  static func validations(_ validations: inout Vapor.Validations) {
    validations.add("grantType", as: String.self, is: .in("password", "refresh_token"))
  }
}

struct PasswordGrantTypePayload: Content, Validatable {
  let clientId: String
  
  // TODO: some implementations send credentials on Authorization header using base64
  // TODO: username is actually `email`, check what is the standard
  let username: String
  let password: String?

  static func validations(_ validations: inout Vapor.Validations) {
    validations.add("username", as: String.self, is: .email)
    validations.add("password", as: String.self, is: !.empty, required: false)
  }
}

struct RefreshTokenGrantTypePayload: Content, Validatable {
  let clientId: String
  let refreshToken: String

  static func validations(_ validations: inout Vapor.Validations) {
    validations.add("refreshToken", as: String.self, is: !.empty)
  }
}
