import AWSDynamoDB

struct UserEmailMethod {
  let email: String
  let passwordHash: String
  let userId: String
  
  init(_ attributes: [String: DynamoDBClientTypes.AttributeValue]?) throws {
    guard let attributes else {
      throw RuntimeError("attributes is null")
    }

    self.email = try getStringFromAttribute(attributes["email"])
    self.passwordHash = try getStringFromAttribute(attributes["passwordHash"])
    self.userId = try getStringFromAttribute(attributes["userId"])
  }
}
