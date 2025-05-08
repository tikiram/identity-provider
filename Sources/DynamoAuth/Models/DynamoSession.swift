import AWSDynamoDB
import DynamoUtils
import Foundation

struct DynamoSessionKey {
  let userId: String  // partition key
  let id: String  // sort key

  func item() -> [String: DynamoDBClientTypes.AttributeValue] {
    return [
      "userId": toDynamoValue(userId),
      "id": toDynamoValue(id),
    ]
  }
}

struct DynamoSession {
  let userId: String  // partition key
  let id: String  // sort key

  let refreshTokenHash: String
  let createdAt: Date
  let lastAccessedAt: Date
  let loggedOutAt: Date?

  func item() -> [String: DynamoDBClientTypes.AttributeValue] {
    return [
      "userId": toDynamoValue(userId),
      "id": toDynamoValue(id),
      "refreshTokenHash": toDynamoValue(refreshTokenHash),
      "createdAt": toDynamoValue(createdAt),
      "lastAccessedAt": toDynamoValue(lastAccessedAt),
      "loggedOutAt": toDynamoValue(loggedOutAt),
    ]
  }
}
