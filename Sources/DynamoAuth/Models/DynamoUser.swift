import AWSDynamoDB
import AuthCore
import DynamoUtils
import Foundation

struct DynamoUser: User, Encodable {

  let poolId: String  // partition key
  let id: String  // sort key

  let createdAt: Date
}
