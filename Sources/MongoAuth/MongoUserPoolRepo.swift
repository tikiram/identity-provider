import AuthCore
import Foundation
import Meow

public class MongoUserPoolRepo: UserPoolRepo {

  private let mongoDatabase: MongoDatabase
  private let poolTableName: String
  private let userPoolTableName: String
  private let userId: String

  public init(
    _ mongoDatabase: MongoDatabase,
    _ poolTableName: String,
    _ userPoolTableName: String,
    _ userId: String
  ) {
    self.mongoDatabase = mongoDatabase
    self.poolTableName = poolTableName
    self.userPoolTableName = userPoolTableName
    self.userId = userId
  }

  public func create(
    _ kid: String,
    _ encryptedPrivateKey: String,
    _ encryptedPublicKey: String
  ) async throws {
    let serializedKid = kid.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()

    let pool = MongoPool(
      _id: serializedKid,
      createdBy: self.userId,
      encryptedPrivateKey: encryptedPrivateKey,
      encryptedPublicKey: encryptedPublicKey,
      createdAt: Date()
    )

    let userPool = MongoUserPool(
      _id: ObjectId(),
      userId: userId,
      poolId: serializedKid
    )

    // Note: transaction not available in local env
    // TODO: check how transactions are handled on mongoDB
    // https://stackoverflow.com/questions/51461952/mongodb-v4-0-transaction-mongoerror-transaction-numbers-are-only-allowed-on-a

    //try await meowDatabase.withTransaction { db in

    let pools = getPoolCollection()
    let userPools = getUserPoolCollection()
    let poolReply = try await pools.insert(pool)

    // TODO: it can exists orphan pools because this is outside of a transaction
    if poolReply.insertCount == 0 {
      throw UserPoolRepoError.unexpectedError(poolReply.debugDescription)
    }

    let userPoolReply = try await userPools.insert(userPool)
    if userPoolReply.insertCount == 0 {
      throw UserPoolRepoError.unexpectedError(userPoolReply.debugDescription)
    }

  }

  private func getPoolCollection(_ db: MeowDatabase? = nil) -> MeowCollection<MongoPool> {
    let meowDatabase = db ?? MeowDatabase(mongoDatabase)
    return MeowCollection<MongoPool>(database: meowDatabase, named: self.poolTableName)
  }

  private func getUserPoolCollection(_ db: MeowDatabase? = nil) -> MeowCollection<MongoUserPool> {
    let meowDatabase = db ?? MeowDatabase(mongoDatabase)
    return MeowCollection<MongoUserPool>(database: meowDatabase, named: self.userPoolTableName)
  }

}
