import AuthCore
import Foundation
import Meow

public class MongoSessionRepo: SessionRepo {

  private let mongoDatabase: MongoDatabase
  private let tableName: String
  private let simpleHashser: SimpleHasher

  public init(
    _ mongoDatabase: MongoDatabase,
    _ tableName: String,
    _ simpleHasher: SimpleHasher
  ) {
    self.mongoDatabase = mongoDatabase
    self.tableName = tableName
    self.simpleHashser = simpleHasher
  }

  public func save(userId: String, sessionId: String, refreshToken: String) async throws {
    let sessions = getCollection()

    let refreshTokenHash = self.simpleHashser.hash(refreshToken)

    let session = MongoSession(
      _id: sessionId,
      userId: userId,
      refreshTokenHash: refreshTokenHash,
      createdAt: Date(),
      lastAccessedAt: Date(),
      loggedOutAt: nil
    )

    let result = try await sessions.insert(session)
    if result.insertCount == 0 {
      throw SessionRepoError.unexpectedError(result.debugDescription)
    }
  }

  public func update(
    sessionId: String,
    newRefreshToken: String,
    previousRefreshToken: String
  ) async throws {
    let sessions = getCollection()

    let previousHash = self.simpleHashser.hash(previousRefreshToken)
    let refreshTokenHash = self.simpleHashser.hash(newRefreshToken)

    let result = try await sessions.updateOne(
      matching: {
        $0.$_id == sessionId
          && $0.$refreshTokenHash == previousHash
          && $0.$loggedOutAt == nil
      },
      build: {
        $0.setField(at: \.$refreshTokenHash, to: refreshTokenHash)
        $0.setField(at: \.$lastAccessedAt, to: Date())
      }
    )

    if result.updatedCount == 0 {
      throw SessionRepoError.tokenOutOfSync
    }
  }

  public func invalidate(sessionId: String, refreshToken: String) async throws {
    let sessions = getCollection()

    let previousHash = self.simpleHashser.hash(refreshToken)

    let result = try await sessions.updateOne(
      matching: {
        $0.$_id == sessionId
          && $0.$refreshTokenHash == previousHash
          && $0.$loggedOutAt == nil
      },
      build: {
        $0.setField(at: \.$loggedOutAt, to: Date())
      }
    )

    if result.updatedCount == 0 {
      throw SessionRepoError.tokenOutOfSync
    }
  }

  private func getCollection() -> MeowCollection<MongoSession> {
    let meowDatabase = MeowDatabase(mongoDatabase)
    return MeowCollection<MongoSession>(database: meowDatabase, named: self.tableName)
  }

}
