import Fluent
import Vapor

final class User: Model, @unchecked Sendable {
  static let schema = "user"

  @ID(key: .id)
  var id: UUID?

  @Field(key: "email")
  var email: String

  @Field(key: "password_hash")
  var passwordHash: String

  init() {}

  init(
    id: UUID? = nil,
    email: String,
    passwordHash: String
  ) {
    self.id = id
    self.email = email
    self.passwordHash = passwordHash
  }
}
