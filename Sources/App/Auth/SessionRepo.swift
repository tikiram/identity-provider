import AWSDynamoDB
import Vapor

class SessionRepo {

  private let client: DynamoDBClient
  private let tableName: String

  init(_ client: DynamoDBClient, tableNamePrefix: String) {
    self.tableName = tableNamePrefix + "auth_session"
    self.client = client
  }

  func save(userId: String, refreshToken: String) async throws {

    let refreshTokenHash = try Bcrypt.hash(refreshToken)

    let input = PutItemInput(
      conditionExpression: "attribute_not_exists(refreshTokenHash)",
      item: [
        "userId": .s(userId),
        "refreshTokenHash": .s(refreshTokenHash),
        "createdAt": .n(nowMS().description),
      ],
      tableName: self.tableName
    )
    let _ = try await client.putItem(input: input)
  }

  func getIsValid(userId: String, refreshToken: String) async throws -> Bool {
    let refreshTokenHash = try Bcrypt.hash(refreshToken)

    let input = GetItemInput(
      key: [
        "userId": .s(userId),
        "refreshTokenHash": .s(refreshTokenHash),
      ],
      tableName: self.tableName
    )

    let output = try await client.getItem(input: input)

    guard let item = output.item else {
      return false
    }

    guard item["deletedAt"] == nil else {
      return false
    }

    return true
  }

  func softDelete(userId: String, refreshToken: String) async throws {
    let refreshTokenHash = try Bcrypt.hash(refreshToken)

    let expression = "SET deletedAt = :deletedAt"
    let expressionAttributeValues: [String: DynamoDBClientTypes.AttributeValue] = [
      ":deletedAt": .n(nowMS().description)
    ]

    let input = UpdateItemInput(
      conditionExpression: "attribute_exists(refreshTokenHash)",
      expressionAttributeValues: expressionAttributeValues,
      key: [
        "userId": .s(userId),
        "refreshTokenHash": .s(refreshTokenHash),
      ],
      tableName: self.tableName,
      updateExpression: expression
    )

    let _ = try await client.updateItem(input: input)
  }
}
