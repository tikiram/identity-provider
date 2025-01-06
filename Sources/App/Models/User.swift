import AWSDynamoDB

struct User {
  let id: String
  
  init(id: String) {
    self.id = id
  }

  init(_ attributes: [String: DynamoDBClientTypes.AttributeValue]?) throws {
    guard let attributes else {
      throw RuntimeError("attributes is null")
    }

    self.id = try getStringFromAttribute(attributes["id"])
  }
}
