import AuthCore
import MongoAuth
import Vapor

extension Request {

  func getUserPoolService(userId: String) throws -> UserPoolService {
    let mongoNames = try self.getMongoNames()

    let userPoolRepo = MongoUserPoolRepo(
      self.mongo,
      mongoNames.pools,
      mongoNames.userPools,
      userId
    )
    return UserPoolService(userPoolRepo, SimpleCipher())
  }

  func getUserPoolService() throws -> UserPoolService {
    let session = try self.getSession()
    return try self.getUserPoolService(userId: session.userId)
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
