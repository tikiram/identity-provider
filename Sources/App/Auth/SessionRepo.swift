import AWSDynamoDB
import Vapor

class SessionRepo {
  
  private let client: DynamoDBClient
  
  init(client: DynamoDBClient) {
    self.client = client
  }
  
  func softDelete(userId: String, refreshToken: String) throws {
    let refreshTokenHash = try Bcrypt.hash(refreshToken)
    let deletedDateMS = Date().timeIntervalSince1970 * 1000
    
    let item: [String: DynamoDBClientTypes.AttributeValue] = [
      "userId": .s(userId),
      "refreshTokenHash": .s(refreshTokenHash),
      "deletedDateMS": .n(deletedDateMS.description)
    ]
  }
  
}
