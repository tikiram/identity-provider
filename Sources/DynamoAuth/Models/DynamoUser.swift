import AWSDynamoDB
import AuthCore
import Foundation
import DynamoUtils

struct DynamoUser: User {

  let poolId: String  // partition key
  let id: String  // sort key

  //
  let createdAt: Date

  func item() -> [String: DynamoDBClientTypes.AttributeValue] {
    return [
      "poolId": toDynamoValue(poolId),
      "id": toDynamoValue(id),
      "createdAt": toDynamoValue(createdAt),
    ]
  }
}



