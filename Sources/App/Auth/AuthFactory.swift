import Meow
// TODO: remove vapor dependency here
import Vapor

enum SourceType {
  case mongoDB
  case dynamoDB
}

struct ClientConfiguration {
  let name: String
  let userSourceType: SourceType
}

// TODO: this dictionary will eventually be migrated to a db
// NOTE: key has to be a valid env name (such as produced with md5)
let clients: [String: ClientConfiguration] = [
  "e0ca5797b2d2b0b63fe1346c5994e7af": ClientConfiguration(
    name: "tensai-dev",
    userSourceType: .mongoDB
  )
]

enum AuthFactoryError: Error {
  case clientNotFound
  case notImplemented
}

protocol UserRepoFactory {
  func get(clientId: String) async throws -> UserRepo
}

class AuthFactory {

  private let mongoUserRepoFactory: MongoUserRepoFactory
  // private let appMongoDatabaseRepo: AppMongoDatabaseRepo
  private let appPasswordHasher: AppPasswordHasher

  init(
    _ mongoUserRepoFactory: MongoUserRepoFactory,
    // appMongoDatabaseRepo: AppMongoDatabaseRepo,
    _ appPasswordHasher: AppPasswordHasher
  ) {
    self.mongoUserRepoFactory = mongoUserRepoFactory
    // self.appMongoDatabaseRepo = appMongoDatabaseRepo
    self.appPasswordHasher = appPasswordHasher
  }

  // TODO: in the future, req will not be required as a param of this function, everything will be obtained from the constructor
  func get(clientId: String, req: Request) async throws -> Auth {
    let config = try getClientConfiguration(clientId)

    let userRepo = try await getUserRepo(clientId, config)

    return try await Auth(req, userRepo, appPasswordHasher)
  }

  private func getUserRepo(
    _ clientId: String,
    _ config: ClientConfiguration
  )
    async throws -> UserRepo
  {
    switch config.userSourceType {
    case .dynamoDB:
      throw AuthFactoryError.notImplemented
    case .mongoDB:
      return try await self.mongoUserRepoFactory.get(clientId: clientId)
    }
  }

  private func getClientConfiguration(_ clientId: String) throws -> ClientConfiguration {
    guard let config = clients[clientId] else {
      throw AuthFactoryError.clientNotFound
    }
    return config
  }
}
