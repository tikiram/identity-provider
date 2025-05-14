import AWSDynamoDB
import AuthCore
import DynamoUtils
import Foundation

struct DynamoUserEmailMethodKey: Encodable {
  let poolId: String  // partition key
  let email: String  // sort key
}

struct DynamoUserEmailMethod: UserEmailMethod, Encodable {
  let poolId: String  // partition key
  let email: String  // sort key

  let passwordHash: String
  let userId: String
  let createdAt: Date

  init(poolId: String, email: String, passwordHash: String, userId: String, createdAt: Date) {
    self.poolId = poolId
    self.email = email
    self.passwordHash = passwordHash
    self.userId = userId
    self.createdAt = createdAt
  }

  init(_ attributes: [String: DynamoDBClientTypes.AttributeValue]) throws {
    self.poolId = try extractString(attributes["poolId"])
    self.email = try extractString(attributes["email"])
    self.passwordHash = try extractString(attributes["passwordHash"])
    self.userId = try extractString(attributes["userId"])
    self.createdAt = try extractDate(attributes["createdAt"])
  }

}
