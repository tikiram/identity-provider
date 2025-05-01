import Foundation
import Meow
import MongoClient
import MongoKitten

final class MongoDBUserRepo: UserRepo {

  private let mongoDatabase: MongoDatabase
  private let appPasswordHasher: AppPasswordHasher

  init(
    mongoDatabase: MongoDatabase,
    appPasswordHasher: AppPasswordHasher
  ) {

    self.mongoDatabase = mongoDatabase
    self.appPasswordHasher = appPasswordHasher
  }

  func create(email: String, password: String) async throws -> User {
    let meow = MeowDatabase(mongoDatabase)
    let users = meow[MongoDBUser.self]

    let serializedEmail = email.trim().lowercased()

    let passwordHash = try await appPasswordHasher.hash(password)
    
    let uniqueId = UUID().uuidString

    let user = MongoDBUser(
      _id: uniqueId,
      createdAt: Date(),
      roles: [],
      email: serializedEmail,
      passwordHash: passwordHash
    )

    let reply = try await users.insert(user)

    let hasDuplicateKeyError =
      reply.writeErrors?.contains { error in
        error.code == 11000
      } ?? false

    guard !hasDuplicateKeyError else {
      throw AuthError.emailAlreadyUsed
    }

    return user
  }
  
  func getUser(userId: String) async throws -> User {
    let meow = MeowDatabase(mongoDatabase)
    let users = meow[MongoDBUser.self]
    
    let user = try await users.findOne {
      $0.$_id == userId
    }
    
    guard let user else {
      throw UserRepoError.userNotFound
    }
    
    return user
  }

  func getEmailMethod(_ email: String) async throws -> UserEmailMethod? {
    let meow = MeowDatabase(mongoDatabase)
    let users = meow[MongoDBUser.self]

    let serializedEmail = email.trim().lowercased()

    let user = try await users.findOne {
      $0.$email == serializedEmail
    }

    return user.map(MongoDBUserEmailMethod.init)
  }
}
