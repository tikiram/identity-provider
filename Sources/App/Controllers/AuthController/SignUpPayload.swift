
import Vapor

struct SignUpPayload: Content, Validatable {
  // TODO: username is actually `email`, check what is the standard
  let username: String
  let password: String
  
  static func validations(_ validations: inout Vapor.Validations) {
    validations.add("username", as: String.self, is: .email)
    validations.add("password", as: String.self, is: !.empty)
  }
}
