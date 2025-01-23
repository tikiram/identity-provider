import AWSDynamoDB
import Vapor

class SessionRepo {

  private let client: DynamoDBClient
  private let tableName: String

  init(_ client: DynamoDBClient, tableNamePrefix: String) {
    self.tableName = tableNamePrefix + "session"
    self.client = client
  }

  func save(userId: String, sessionSubId: String, refreshToken: String) async throws {
    let refreshTokenHash = generateSHA256(from: refreshToken)

    // TODO: save ip, region and other related data, this can help to detect stolen refreshTokens
    let session = Session(userId: userId, subId: sessionSubId, refreshTokenHash: refreshTokenHash)

    let input = PutItemInput(
      conditionExpression: "attribute_not_exists(subId)",
      item: session.item(),
      tableName: self.tableName
    )
    let _ = try await client.putItem(input: input)
  }

  func update(userId: String, sessionSubId: String, newRefreshToken: String, previousRefreshToken: String) async throws {
    let previousHash = generateSHA256(from: previousRefreshToken)
    let refreshTokenHash = generateSHA256(from: newRefreshToken)

    let expression = "SET refreshTokenHash = :x, lastAccessedAt = :y"
    let expressionAttributeValues: [String: DynamoDBClientTypes.AttributeValue] = [
      ":x": .s(refreshTokenHash),
      ":y": .n(Date().millisecondsSince1970.description),
      ":previousHash": .s(previousHash)
    ]

    let input = UpdateItemInput(
      conditionExpression: "refreshTokenHash = :previousHash AND attribute_not_exists(loggedOutAt)",
      expressionAttributeValues: expressionAttributeValues,
      key: SessionId(userId, sessionSubId).key(),
      tableName: self.tableName,
      updateExpression: expression
    )

    let _ = try await client.updateItem(input: input)
  }

  func delete(userId: String, sessionSubId: String, refreshToken: String) async throws {
    let previousHash = generateSHA256(from: refreshToken)

    let expression = "SET loggedOutAt = :x"
    let expressionAttributeValues: [String: DynamoDBClientTypes.AttributeValue] = [
      ":previousHash": .s(previousHash),
      ":x": .n(Date().millisecondsSince1970.description)
    ]

    let input = UpdateItemInput(
      conditionExpression: "refreshTokenHash = :previousHash AND attribute_not_exists(loggedOutAt)",
      expressionAttributeValues: expressionAttributeValues,
      key: SessionId(userId, sessionSubId).key(),
      tableName: self.tableName,
      updateExpression: expression
    )

    let _ = try await client.updateItem(input: input)
  }
}
