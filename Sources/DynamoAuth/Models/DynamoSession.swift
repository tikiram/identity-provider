import AWSDynamoDB
import DynamoUtils
import Foundation

struct DynamoSessionKey: Encodable {
  let userId: String  // partition key
  let id: String  // sort key

}

struct DynamoSession: Encodable {
  let userId: String  // partition key
  let id: String  // sort key

  let refreshTokenHash: String
  let createdAt: Date
  let lastAccessedAt: Date
  let loggedOutAt: Date?
}
