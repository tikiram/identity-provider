import AuthCore
import Foundation
import Meow

public class MongoSessionRepo: SessionRepo {

  private let mongoDatabase: MongoDatabase
  private let tableName: String
  // private let simpleHashser: SimpleHasher

  public init(
    _ mongoDatabase: MongoDatabase,
    _ tableName: String
  ) {
    self.mongoDatabase = mongoDatabase
    self.tableName = tableName
  }

  public func save(userId: String, sessionId: String, refreshTokenHash: String) async throws {
    let sessions = getCollection()

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
    userId: String,  // not used but required by the protocol
    sessionId: String,
    newRefreshTokenHash: String,
    previousRefreshTokenHash: String
  ) async throws {
    let sessions = getCollection()

    let result = try await sessions.updateOne(
      matching: {
        $0.$_id == sessionId
          && $0.$refreshTokenHash == previousRefreshTokenHash
          && $0.$loggedOutAt == nil
      },
      build: {
        $0.setField(at: \.$refreshTokenHash, to: newRefreshTokenHash)
        $0.setField(at: \.$lastAccessedAt, to: Date())
      }
    )

    if result.updatedCount == 0 {
      throw SessionRepoError.tokenOutOfSync
    }
  }

  public func invalidate(
    userId: String,  // not used but required by the protocol
    sessionId: String,
    refreshTokenHash: String
  ) async throws {
    let sessions = getCollection()

    let result = try await sessions.updateOne(
      matching: {
        $0.$_id == sessionId
          && $0.$refreshTokenHash == refreshTokenHash
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
