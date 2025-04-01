import Meow

class MongoUserRepoFactory: UserRepoFactory {

  private let mongoDatabaseFactory: MongoDatabaseFactory
  private let appPasswordHasher: AppPasswordHasher

  private var repos: [String: UserRepo] = [:]

  init(
    _ mongoDatabaseFactory: MongoDatabaseFactory,
    _ appPasswordHasher: AppPasswordHasher
  ) {
    self.mongoDatabaseFactory = mongoDatabaseFactory
    self.appPasswordHasher = appPasswordHasher
  }

  func get(clientId: String) async throws -> UserRepo {
    if let repo = repos[clientId] {
      // Note: instance is reused to skip indexes validation
      return repo
    }

    let mongoDatabase = try await self.mongoDatabaseFactory.getMongoDatabase(clientId)

    let meow = MeowDatabase(mongoDatabase)
    let users = meow[MongoDBUser.self]

    try await users.buildIndexes { _ in

      UniqueIndex(
        named: "unique-email",
        field: "email"
      )

//      TextScoreIndex(
//        named: "search-email",
//        field: "email"
//      )
    }

    // Setup Indexes here

    let repo = MongoDBUserRepo(mongoDatabase: mongoDatabase, appPasswordHasher: appPasswordHasher)

    self.repos[clientId] = repo
    return repo
  }
}
