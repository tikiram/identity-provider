import Vapor

struct ResetPasswordPayload: Content, Validatable {
  let email: String

  static func validations(_ validations: inout Vapor.Validations) {
    validations.add("email", as: String.self, is: .email)
  }
}
