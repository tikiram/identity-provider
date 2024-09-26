import Vapor

enum GrandType: String, Codable {
  case password
  case refreshToken = "refresh_token"
}

struct TokensPayload: Content, Validatable {
  let grandType: GrandType

  static func validations(_ validations: inout Vapor.Validations) {
    validations.add("grandType", as: String.self, is: .in("password", "refresh_token"))
  }
}

struct PasswordGrandTypePayload: Content, Validatable {
  // TODO: some implementations send credentials on Authorization header using base64
  // TODO: username is actually `email`, check what is the standard
  let username: String
  let password: String?

  static func validations(_ validations: inout Vapor.Validations) {
    validations.add("username", as: String.self, is: .email)
    validations.add("password", as: String.self, is: !.empty, required: false)
  }
}

struct RefreshTokenGrandTypePayload: Content, Validatable {
  let refreshToken: String

  static func validations(_ validations: inout Vapor.Validations) {
    validations.add("refreshToken", as: String.self, is: !.empty)
  }
}
