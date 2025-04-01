import Vapor

struct SignUpPayload: Content, Validatable {
  let clientId: String
  // TODO: username is actually `email`, check what is the standard
  let username: String
  let password: String

  static func validations(_ validations: inout Vapor.Validations) {
    validations.add("clientId", as: String.self)
    validations.add("username", as: String.self, is: .email)
    // TODO: check how to enforce strong passwords
    validations.add("password", as: String.self)
  }
}
