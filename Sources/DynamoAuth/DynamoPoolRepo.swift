import AWSDynamoDB
import AuthCore
import DynamoUtils

public class DynamoPoolRepo: PoolRepo {

  private let client: DynamoDBClient
  private let tableName: String

  public init(_ client: DynamoDBClient, _ tableName: String) {
    self.client = client
    self.tableName = tableName
  }

  public func getAll() async throws -> [any Pool] {

    let input = ScanInput(
      limit: 10,
      tableName: self.tableName
    )

    let output = try await client.scan(input: input)

    guard let items = output.items else {
      return []
    }

    return try items.map { try decode(DynamoPool.self, $0) }
  }

}
