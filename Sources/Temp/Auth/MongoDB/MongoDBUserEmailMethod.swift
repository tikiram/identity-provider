class MongoDBUserEmailMethod: UserEmailMethod {
  let userId: String
  let email: String
  let passwordHash: String

  init(user: MongoDBUser) {
    self.userId = user.id
    self.email = user.email
    self.passwordHash = user.passwordHash
  }
}
