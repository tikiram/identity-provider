import AWSDynamoDB
import SharedBackend

struct DynamoDBUser: User {
  
  // TODO: support roles on DynamoDB?
  let roles: [String]
  
  let id: String

  init(id: String, roles: [String]) {
    self.id = id
    self.roles = roles
  }

  init(_ attributes: [String: DynamoDBClientTypes.AttributeValue]?) throws {
    guard let attributes else {
      throw RuntimeError("attributes is null")
    }

    self.id = try getStringFromAttribute(attributes["id"])
    // TODO: support roles ?
    self.roles = []
  }
}

