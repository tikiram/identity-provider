import MongoKitten
import Vapor


extension Request {
  var mongoUserRepoFactory: MongoUserRepoFactory {
    return MongoUserRepoFactory(self.mongoDatabaseFactory, self.appPasswordHasher)
  }
}

extension Request {
  var mongoSessionRepoFactory: MongoSessionRepoFactory {
    return MongoSessionRepoFactory(self.mongoDatabaseFactory)
  }
}
