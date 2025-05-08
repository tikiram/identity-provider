import Utils
import Vapor

extension Request {

  func getMongoNames() throws -> MongoNames {
    guard let names = self.application.mongoNames else {
      throw RuntimeError("MongoNames not defined")
    }
    return names
  }
}
