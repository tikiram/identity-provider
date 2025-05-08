import AWSDynamoDB
import AuthCore

class DynamoPoolRepo: PoolRepo {

  private let client: DynamoDBClient
  private let tableName: String

  init(_ client: DynamoDBClient, _ tableName: String) {
    self.client = client
    self.tableName = tableName
  }

  func getAll() async throws -> [any Pool] {

    let input = QueryInput(
      limit: 10,
      scanIndexForward: false,
      tableName: self.tableName
    )

    let output = try await client.query(input: input)

    guard let items = output.items else {
      return []
    }

    return try items.map(DynamoPool.init)
  }

}
