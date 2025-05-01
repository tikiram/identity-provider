import Foundation

public enum UserRepoError: Error {
  case userNotFound
  case emailAlreadyUsed
  case unexpectedError(String)
}

public protocol UserRepo: Sendable {

  func create(email: String, passwordHash: String) async throws -> User

  func getEmailMethod(_ email: String) async throws -> UserEmailMethod?

  func getUser(userId: String) async throws -> User
}
