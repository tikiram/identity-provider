import Foundation
import Meow

let a = 3
let b = 4

class MongoSessionRepo: SessionRepo {

  private let mongoDatabase: MongoDatabase

  init(
    mongoDatabase: MongoDatabase
  ) {
    self.mongoDatabase = mongoDatabase
  }

  func save(userId: String, sessionSubId: String, refreshToken: String) async throws {
    let meow = MeowDatabase(mongoDatabase)
    let sessions = meow[MongoSession.self]

    let refreshTokenHash = generateSHA256(from: refreshToken)

    let session = MongoSession(
      _id: sessionSubId,
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

  func update(
    userId: String,
    sessionSubId: String,
    newRefreshToken: String,
    previousRefreshToken: String
  ) async throws {
    let meow = MeowDatabase(mongoDatabase)
    let sessions = meow[MongoSession.self]

    let previousHash = generateSHA256(from: previousRefreshToken)
    let refreshTokenHash = generateSHA256(from: newRefreshToken)

    let result = try await sessions.updateOne(
      matching: {
        $0.$_id == sessionSubId
          && $0.$refreshTokenHash == previousHash
          && $0.$loggedOutAt == nil
      },
      build: {
        $0.setField(at: \.$refreshTokenHash, to: refreshTokenHash)
        $0.setField(at: \.$lastAccessedAt, to: Date())
      }
    )

    if result.updatedCount == 0 {
      
      print("result----")
      print(result.ok)
      print(result.localizedDescription)
      
      throw SessionRepoError.tokenOutOfSync
    }
  }

  func invalidate(userId: String, sessionSubId: String, refreshToken: String) async throws {
    let meow = MeowDatabase(mongoDatabase)
    let sessions = meow[MongoSession.self]

    let previousHash = generateSHA256(from: refreshToken)

    let result = try await sessions.updateOne(
      matching: {
        $0.$_id == sessionSubId
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

}
