import AWSDynamoDB
import AuthCore
import DynamoUtils
import Foundation

struct DynamoPool: Pool, Encodable {
  let createdBy: String  // partition key
  let id: String  // sort key

  let encryptedPrivateKey: String
  let encryptedPublicKey: String
  let createdAt: Date

  init(
    createdBy: String,
    id: String,
    encryptedPrivateKey: String,
    encryptedPublicKey: String,
    createdAt: Date
  ) {
    self.createdBy = createdBy
    self.id = id
    self.encryptedPrivateKey = encryptedPrivateKey
    self.encryptedPublicKey = encryptedPublicKey
    self.createdAt = createdAt
  }

  init(_ attributes: [String: DynamoDBClientTypes.AttributeValue]) throws {
    self.createdBy = try extractString(attributes["createdBy"])
    self.id = try extractString(attributes["id"])
    self.encryptedPrivateKey = try extractString(attributes["encryptedPrivateKey"])
    self.encryptedPublicKey = try extractString(attributes["encryptedPublicKey"])
    self.createdAt = try extractDate(attributes["createdAt"])
  }
}
