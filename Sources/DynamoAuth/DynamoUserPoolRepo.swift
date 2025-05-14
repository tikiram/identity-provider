import AWSDynamoDB
import AuthCore
import Foundation
import DynamoUtils

public class DynamoUserPoolRepo: UserPoolRepo {

  private let client: DynamoDBClient
  private let tableName: String
  private let userId: String

  public init(
    _ client: DynamoDBClient,
    _ tableName: String,
    _ userId: String
  ) {
    self.client = client
    self.tableName = tableName
    self.userId = userId
  }

  public func create(
    _ kid: String,
    _ encryptedPrivateKey: String,
    _ encryptedPublicKey: String
  ) async throws {
    let serializedKid = kid.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()

    let pool = DynamoPool(
      createdBy: self.userId,
      id: serializedKid,
      encryptedPrivateKey: encryptedPrivateKey,
      encryptedPublicKey: encryptedPublicKey,
      createdAt: Date()
    )

    let input = PutItemInput(
      conditionExpression: "attribute_not_exists(id)",
      item: try toDynamoItem(pool),
      tableName: self.tableName
    )
    let _ = try await client.putItem(input: input)
  }

}
