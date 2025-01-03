import AWSDynamoDB
import Vapor

class SessionRepo {
  
  private let client: DynamoDBClient
  private let tableName: String
  
  init(client: DynamoDBClient, tableName: String) {
    self.tableName = tableName
    self.client = client
  }
  
  func save(userId: String, refreshToken: String) async throws {
    
    let refreshTokenHash = try Bcrypt.hash(refreshToken)
    let createdDateMS = Date().timeIntervalSince1970 * 1000
    
    let input = PutItemInput(
      conditionExpression: "attribute_not_exists(refreshTokenHash)",
      item: [
        "userId": .s(userId),
        "refreshTokenHash": .s(refreshTokenHash),
        "createdDateMS": .n(createdDateMS.description)
      ],
      tableName: self.tableName
    )
    let output = try await client.putItem(input: input)    
  }
  
  func getIsValid(userId: String, refreshToken: String) async throws -> Bool {
    let refreshTokenHash = try Bcrypt.hash(refreshToken)
    
    let input = GetItemInput(
      key: [
        "userId": .s(userId),
        "refreshTokenHash": .s(refreshTokenHash)
      ],
      tableName: self.tableName
    )
    
    let output = try await client.getItem(input: input)
    
    guard let item = output.item else {
      return false
    }
    
    guard item["deletedDateMS"] == nil else {
      return false
    }
    
    return true
  }
  
  func softDelete(userId: String, refreshToken: String) async throws {
    let refreshTokenHash = try Bcrypt.hash(refreshToken)
    let deletedDateMS = Date().timeIntervalSince1970 * 1000
    
    let expression = "SET deletedDateMS = :deletedDateMS"
    let expressionAttributeValues: [String: DynamoDBClientTypes.AttributeValue] = [
      ":deletedDateMS": .n(deletedDateMS.description)
    ]
    
    let input = UpdateItemInput(
      conditionExpression: "attribute_exists(refreshTokenHash)",
      expressionAttributeValues: expressionAttributeValues,
      key: [
        "userId": .s(userId),
        "refreshTokenHash": .s(refreshTokenHash)
      ],
      tableName: self.tableName,
      updateExpression: expression
    )
    
    let output = try await client.updateItem(input: input)
  }
}
