import AWSDynamoDB
import CryptoKit
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

  func getIsValid(userId: String, sessionSubId: String, refreshToken: String) async throws -> Bool {

    let sessionId = SessionId(userId, sessionSubId)

    let input = GetItemInput(
      key: sessionId.key(),
      tableName: self.tableName
    )

    let output = try await client.getItem(input: input)

    guard let item = output.item else {
      return false
    }

    let session = try Session(item)

    let refreshTokenHash = generateSHA256(from: refreshToken)

    return session.refreshTokenHash == refreshTokenHash
  }

  func update(userId: String, sessionSubId: String, refreshToken: String) async throws {
    let refreshTokenHash = generateSHA256(from: refreshToken)

    let expression = "SET refreshTokenHash = :x, lastAccessedAt = :y"
    let expressionAttributeValues: [String: DynamoDBClientTypes.AttributeValue] = [
      ":x": .s(refreshTokenHash),
      ":y": .n(Date().millisecondsSince1970.description),
    ]

    let input = UpdateItemInput(
      conditionExpression: "attribute_exists(subId)",
      expressionAttributeValues: expressionAttributeValues,
      key: SessionId(userId, sessionSubId).key(),
      tableName: self.tableName,
      updateExpression: expression
    )

    let _ = try await client.updateItem(input: input)
  }

  func delete(userId: String, sessionSubId: String) async throws {
    let input = DeleteItemInput(
      key: SessionId(userId, sessionSubId).key(),
      tableName: self.tableName
    )
    _ = try await client.deleteItem(input: input)

    // we can implement soft delete (if required) by saving deleted item in another table
  }
}
