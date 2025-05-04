import AuthCore
import Meow

public class MongoPoolRepo: PoolRepo {

  private let mongoDatabase: MongoDatabase
  private let tableName: String

  public init(
    _ mongoDatabase: MongoDatabase,
    _ tableName: String
  ) {
    self.mongoDatabase = mongoDatabase
    self.tableName = tableName
  }

  public func getAll() async throws -> [any Pool] {
    let pools = getCollection()

    let poolItems = try await pools.find().drain()

    return poolItems
  }

  private func getCollection() -> MeowCollection<MongoPool> {
    let meowDatabase = MeowDatabase(mongoDatabase)
    return MeowCollection<MongoPool>(database: meowDatabase, named: self.tableName)
  }

}
