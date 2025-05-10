import Utils
import Vapor

struct DynamoNames {
  let users: String
  let userEmailMethod: String
  let sessions: String
  let pools: String
  // let userPools: String // not implemented in DynamoDB
}

private struct DynamoNamesKey: StorageKey {
  typealias Value = DynamoNames
}

extension Application {
  var dynamoNames: DynamoNames? {
    get {
      storage[DynamoNamesKey.self]
    }
    set {
      storage[DynamoNamesKey.self] = newValue
    }
  }
}

extension Application {
  func getDynamoNames() throws -> DynamoNames {
    guard let dynamoNames = self.dynamoNames else {
      throw RuntimeError("MongoNames not defined")
    }
    return dynamoNames
  }
}
