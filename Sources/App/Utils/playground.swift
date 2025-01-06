import AWSClientRuntime
import AWSDynamoDB
import Foundation

func something() async throws {

  // region: "us-east-1"

  //  let client = try DynamoDBClient(region: "us-east-1")
  let client = try await DynamoDBClient()

  let input = QueryInput(
    expressionAttributeNames: [
      "#y": "year"
    ],
    expressionAttributeValues: [
      ":y": .n(String(1234))
    ],
    keyConditionExpression: "#y = :y",
    tableName: "some_table"
  )
  // Use "Paginated" to get all the movies.
  // This lets the SDK handle the 'lastEvaluatedKey' property in "QueryOutput".

  let tables = try await client.listTables(input: ListTablesInput())

  print(tables)

  //  let pages = client.queryPaginated(input: input)
  //  print(pages)

}
