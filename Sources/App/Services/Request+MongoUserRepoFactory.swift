import MongoKitten
import Vapor

private struct MongoUserReposKey: StorageKey {
  typealias Value = [String: UserRepo]
}

extension Application {
  var mongoUserRepos: [String: UserRepo]? {
    get {
      storage[MongoUserReposKey.self]
    }
    set {
      storage[MongoUserReposKey.self] = newValue
    }
  }
}

extension Request {
  var mongoUserRepoFactory: MongoUserRepoFactory {
    return MongoUserRepoFactory(self.mongoDatabaseFactory, self.appPasswordHasher)
  }
}
