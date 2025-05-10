import AuthCore
import DynamoAuth
import MongoAuth
import Vapor

extension Request {

  private func getMongoUserPoolService(userId: String) throws -> UserPoolService {
    let mongoNames = try self.getMongoNames()

    let userPoolRepo = MongoUserPoolRepo(
      self.mongo,
      mongoNames.pools,
      mongoNames.userPools,
      userId
    )
    return UserPoolService(userPoolRepo, SimpleCipher())
  }

  private func getDynamoUserPoolService(userId: String) throws -> UserPoolService {
    let dynamoNames = try self.application.getDynamoNames()

    let userPoolRepo = DynamoUserPoolRepo(
      self.application.dynamo,
      dynamoNames.pools,
      userId
    )
    return UserPoolService(userPoolRepo, SimpleCipher())
  }

  func getBUserPoolService() throws -> UserPoolService {
    let session = try self.getSession()
    return try self.getMongoUserPoolService(userId: session.userId)
  }

  func getCUserPoolService() throws -> UserPoolService {
    let session = try self.getSession()
    return try self.getMongoUserPoolService(userId: session.userId)
  }

}

class SimpleCipher: DataCipher {
  func encrypt(_ message: String) -> String {
    return message
  }

  func decrypt(_ encryptedMessage: String) -> String {
    return encryptedMessage
  }

}
