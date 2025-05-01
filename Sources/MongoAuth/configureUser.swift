import Meow

public class MongoAuthManager {

  private let mongoDatabase: MongoDatabase

  public init(_ mongoDatabase: MongoDatabase) {
    self.mongoDatabase = mongoDatabase
  }

  public func configureUsers(_ tableName: String) async throws {

    let meowDatabase = MeowDatabase(mongoDatabase)
    let users = MeowCollection<MongoUser>(database: meowDatabase, named: tableName)

    try await users.buildIndexes { m in

      SortedIndex(
        by: [
          m.$poolId.path.string: .ascending,
          m.$email.path.string: .ascending,
        ],
        named: "unique-email-within-realm"
      )
      .unique()

      SortedIndex(
        by: [
          m.$_id.path.string: .ascending,
          m.$poolId.path.string: .ascending,
        ],
        named: "search-by-id-and-realm"
      )

      SortedIndex(
        by: [
          m.$poolId.path.string: .ascending,
          m.$email.path.string: .ascending,
        ],
        named: "search-by-email-and-realm"
      )
    }
  }

  public func configureSession(_ tableName: String) async throws {

    let meowDatabase = MeowDatabase(mongoDatabase)
    let sessions = MeowCollection<MongoSession>(database: meowDatabase, named: tableName)

    try await sessions.buildIndexes { m in

      SortedIndex(
        by: [
          m.$_id.path.string: .ascending,
          m.$refreshTokenHash.path.string: .ascending,
          m.$loggedOutAt.path.string: .ascending,
        ],
        named: "search-index"
      )
    }
  }

}
