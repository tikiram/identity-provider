@preconcurrency import AWSDynamoDB
import MongoKitten
import Vapor

private struct DynamoStorageKey: StorageKey {
  typealias Value = DynamoDBClient
}

extension Application {
  public var dynamo: DynamoDBClient {
    get {
      storage[DynamoStorageKey.self]!
    }
    set {
      storage[DynamoStorageKey.self] = newValue
    }
  }

  public func initializeDynamo() async throws {
    self.dynamo = try await DynamoDBClient()
  }
}
