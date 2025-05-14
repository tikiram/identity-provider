import AWSDynamoDB
import AuthCore
import DynamoUtils
import Foundation

struct DynamoUserEmailMethodKey: Encodable {
  let poolId: String  // partition key
  let email: String  // sort key
}

struct DynamoUserEmailMethod: UserEmailMethod, Codable {
  let poolId: String  // partition key
  let email: String  // sort key

  let passwordHash: String
  let userId: String
  let createdAt: Date
}
