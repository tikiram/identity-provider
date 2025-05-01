import Meow

class MongoSessionRepoFactory: SessionRepoFactory {

  private let mongoDatabaseFactory: MongoDatabaseFactory

  private var repos: [String: SessionRepo] = [:]

  init(
    _ mongoDatabaseFactory: MongoDatabaseFactory
  ) {
    self.mongoDatabaseFactory = mongoDatabaseFactory
  }

  func get(clientId: String) async throws -> SessionRepo {
    if let repo = repos[clientId] {
      // Note: instance is reused to skip indexes validation
      return repo
    }

    let mongoDatabase = try await self.mongoDatabaseFactory.getMongoDatabase(clientId)

    let meow = MeowDatabase(mongoDatabase)
    let sessions = meow[MongoSession.self]

    try await sessions.buildIndexes { _ in

      // Note: TextScoreIndex seems not working
      // TextScoreIndex(named: "email-search", field: "email")
      // Use this instead
      // SortedIndex(named: "email-search", field: "email", order: .custom("text"))

      SortedIndex(
        by: [
          "_id": .ascending,
          "refreshTokenHash": .ascending,
          "loggedOutAt": .ascending,
        ],
        named: "search-index"
      )
    }

    // Setup Indexes here

    let repo = MongoSessionRepo(mongoDatabase: mongoDatabase)

    self.repos[clientId] = repo
    return repo
  }
}
