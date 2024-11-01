import Fluent
import Vapor

final class ResetAttempt: Model, @unchecked Sendable {
  static let schema = "reset_attempt"

  @ID(key: .id)
  var id: UUID?
  
  @Parent(key: "user_id")
  var user: User

  @Field(key: "email")
  var email: String
  
  @Field(key: "code")
  var code: String

  init() {}

  init(userID: User.IDValue, email: String, code: String) {
    $user.id = userID
    self.email = email
    self.code = code
  }
}
