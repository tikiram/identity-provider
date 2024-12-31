
import AWSClientRuntime
import AWSDynamoDB
import Foundation


func something() async throws {
  

  let configuration =  try await DynamoDBClient.DynamoDBClientConfiguration(region: "us-east-1")
  

  
  let client = DynamoDBClient(config: configuration)

}



