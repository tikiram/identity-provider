import AWSDynamoDB
import AuthCore
import DynamoUtils
import Foundation

struct DynamoPool: Pool, Codable {
  let createdBy: String  // partition key
  let id: String  // sort key

  let encryptedPrivateKey: String
  let encryptedPublicKey: String
  let createdAt: Date
}
