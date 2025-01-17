import AWSDynamoDB
import Vapor

class UserRepo {

  private let client: DynamoDBClient
  private let userTableName: String
  private let userEmailMethodTableName: String

  init(_ client: DynamoDBClient, tableNamePrefix: String) {
    self.client = client

    self.userTableName = tableNamePrefix + "user"
    self.userEmailMethodTableName = tableNamePrefix + "user_email_method"
  }

  func create(email: String, password: String) async throws -> User {
    let uniqueID = UUID().uuidString
    let serializedEmail = email.trim().lowercased()
    let passwordHash = try Bcrypt.hash(password)

    let put1 = DynamoDBClientTypes.Put(
      conditionExpression: "attribute_not_exists(id)",
      item: [
        "id": .s(uniqueID),
        "createdAt": .n(Date().millisecondsSince1970.description),
      ],
      tableName: self.userTableName
    )
    let item1 = DynamoDBClientTypes.TransactWriteItem(put: put1)

    let put2 = DynamoDBClientTypes.Put(
      conditionExpression: "attribute_not_exists(email)",
      item: [
        "email": .s(serializedEmail),
        "passwordHash": .s(passwordHash),
        "createdAt": .n(Date().millisecondsSince1970.description),
        "userId": .s(uniqueID),
      ],
      tableName: self.userEmailMethodTableName
    )
    let item2 = DynamoDBClientTypes.TransactWriteItem(put: put2)

    let input = TransactWriteItemsInput(transactItems: [item2, item1])
    let _ = try await client.transactWriteItems(input: input)

    let user = User(id: uniqueID)
    return user
  }

  func getEmailMethod(_ email: String) async throws -> UserEmailMethod? {
    let serializedEmail = email.trim().lowercased()

    let input = GetItemInput(
      consistentRead: false,
      key: [
        "email": .s(serializedEmail)
      ],
      tableName: self.userEmailMethodTableName
    )

    let output = try await client.getItem(input: input)

    guard let item = output.item else {
      return nil
    }

    return try UserEmailMethod(item)
  }
}
