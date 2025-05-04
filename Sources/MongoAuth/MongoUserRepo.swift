import AuthCore
import Foundation
import Meow

public final class MongoUserRepo: UserRepo {

  private let mongoDatabase: MongoDatabase
  private let tableName: String
  private let poolId: String?

  public init(
    _ mongoDatabase: MongoDatabase,
    _ tableName: String,
    _ poolId: String?
  ) {
    self.mongoDatabase = mongoDatabase
    self.tableName = tableName
    self.poolId = poolId
  }

  // TODO: validate pool id exists if received

  public func create(email: String, passwordHash: String) async throws -> User {
    let users = getCollection()

    let serializedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()

    let uniqueId = UUID().uuidString

    let user = MongoUser(
      _id: uniqueId,
      poolId: self.poolId,
      createdAt: Date(),
      roles: [],
      email: serializedEmail,
      passwordHash: passwordHash
    )

    let reply = try await users.insert(user)

    guard reply.insertCount != 0 else {
      let hasDuplicateKeyError =
        reply.writeErrors?.contains { error in
          error.code == 11000
        } ?? false

      if hasDuplicateKeyError {
        throw UserRepoError.emailAlreadyUsed
      } else {
        throw UserRepoError.unexpectedError(reply.debugDescription)
      }
    }

    return user
  }

  public func getUser(userId: String) async throws -> User {
    let users = getCollection()

    let user = try await users.findOne {
      $0.$_id == userId && $0.$poolId == self.poolId
    }

    guard let user else {
      throw UserRepoError.userNotFound
    }

    return user
  }

  public func getEmailMethod(_ email: String) async throws -> UserEmailMethod? {
    let users = getCollection()

    let serializedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()

    let user = try await users.findOne {
      $0.$poolId == self.poolId && $0.$email == serializedEmail
    }

    return user
  }

  private func getCollection() -> MeowCollection<MongoUser> {
    let meowDatabase = MeowDatabase(mongoDatabase)
    return MeowCollection<MongoUser>(database: meowDatabase, named: self.tableName)
  }

}
