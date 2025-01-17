import AWSDynamoDB
import Foundation
import SharedBackend

struct SessionId {
  let userId: String
  let subId: String

  init(_ userId: String, _ subId: String) {
    self.userId = userId
    self.subId = subId
  }

  func key() -> [String: DynamoDBClientTypes.AttributeValue] {
    return [
      "userId": .s(userId),
      "subId": .s(subId),
    ]
  }
}

struct Session {

  // Note: it may be a good idea to define the PK with the FolderPK struct instead of these fields
  // partition key
  let userId: String
  // sort key
  let subId: String

  let refreshTokenHash: String
  let createdAt: Date
  let lastAccessedAt: Date

  init(userId: String, subId: String, refreshTokenHash: String) {
    self.userId = userId
    self.subId = subId
    self.refreshTokenHash = refreshTokenHash
    self.createdAt = Date()
    self.lastAccessedAt = Date()
  }

  init(_ attributes: [String: DynamoDBClientTypes.AttributeValue]?) throws {
    guard let attributes else {
      throw RuntimeError("attributes is null")
    }
    self.userId = try getStringFromAttribute(attributes["userId"])
    self.subId = try getStringFromAttribute(attributes["subId"])
    self.refreshTokenHash = try getStringFromAttribute(attributes["refreshTokenHash"])
    self.createdAt = try getDateFromAttribute(attributes["createdAt"])
    self.lastAccessedAt = try getDateFromAttribute(attributes["lastAccessedAt"])
  }

  func item() -> [String: DynamoDBClientTypes.AttributeValue] {
    return [
      "userId": .s(userId),
      "subId": .s(subId),
      "refreshTokenHash": .s(refreshTokenHash),
      "createdAt": .n(self.createdAt.millisecondsSince1970.description),
      "lastAccessedAt": .n(self.lastAccessedAt.millisecondsSince1970.description),
    ]
  }
}
