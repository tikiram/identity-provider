
import AWSClientRuntime
import AWSDynamoDB
import Vapor

extension Request {
  var dynamoDBClient: DynamoDBClient {
    get async throws {
      return try await DynamoDBClient()
    }
  }
}
