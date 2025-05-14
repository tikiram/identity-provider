import AWSDynamoDB
import AuthCore
import DynamoUtils
import Foundation

// DynamoDB needs a non empty value as partition key
private let MASTER_POOL_ID = "<master>"

public class DynamoUserRepo: UserRepo {

  private let client: DynamoDBClient
  private let userTableName: String
  private let emailMethodTableName: String
  private let poolId: String

  public init(
    _ client: DynamoDBClient,
    _ userTableName: String,
    _ emailMethodTableName: String,
    _ poolId: String?
  ) {
    self.client = client
    self.userTableName = userTableName
    self.emailMethodTableName = emailMethodTableName
    self.poolId = poolId ?? MASTER_POOL_ID
  }

  public func create(email: String, passwordHash: String) async throws -> any User {
    do {
      return try await createOnDynamo(email: email, passwordHash: passwordHash)
    } catch let error as TransactionCanceledException where conditionalCheckFailed(error) {
      throw UserRepoError.emailAlreadyUsed
    }
  }

  private func createOnDynamo(email: String, passwordHash: String) async throws -> User {
    let uniqueID = UUID().uuidString
    let serializedEmail = email.trim().lowercased()

    let user = DynamoUser(poolId: self.poolId, id: uniqueID, createdAt: Date())

    let put1 = DynamoDBClientTypes.Put(
      // conditionExpression: "attribute_not_exists(id)",
      item: try toDynamoItem(user),
      tableName: self.userTableName
    )
    let item1 = DynamoDBClientTypes.TransactWriteItem(put: put1)

    let emailMethod = DynamoUserEmailMethod(
      poolId: self.poolId,
      email: serializedEmail,
      passwordHash: passwordHash,
      userId: uniqueID,
      createdAt: Date()
    )

    let put2 = DynamoDBClientTypes.Put(
      conditionExpression: "attribute_not_exists(email)",
      item: try toDynamoItem(emailMethod),
      tableName: self.emailMethodTableName
    )
    let item2 = DynamoDBClientTypes.TransactWriteItem(put: put2)

    let input = TransactWriteItemsInput(transactItems: [item2, item1])
    let _ = try await client.transactWriteItems(input: input)

    return user
  }

  public func getEmailMethod(_ email: String) async throws -> (any UserEmailMethod)? {
    let serializedEmail = email.trim().lowercased()

    let key = DynamoUserEmailMethodKey(poolId: self.poolId, email: serializedEmail)

    let input = GetItemInput(
      consistentRead: false,
      key: try toDynamoItem(key),
      tableName: self.emailMethodTableName
    )

    let output = try await client.getItem(input: input)

    guard let item = output.item else {
      return nil
    }

    return try decode(DynamoUserEmailMethod.self, item)
  }

  public func getUser(userId: String) async throws -> any User {
    // TODO: implement this if needed, currently User only has the id field
    return DynamoUser(poolId: "", id: userId, createdAt: Date())
  }

}
