import SharedBackend
import Vapor

extension Request {

//  var sessionRepo: SessionRepo {
//    get async throws {
//      return try await SessionRepo(
//        self.dynamoDBClient, tableNamePrefix: "\(self.environmentShortName)_auth_")
//    }
//  }

  var userRepo: UserRepo {
    get async throws {
      return try await DynamoDBUserRepo(
        self.dynamoDBClient, tableNamePrefix: "\(self.environmentShortName)_auth_")
    }
  }

}
