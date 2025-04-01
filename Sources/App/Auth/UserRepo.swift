import Foundation

protocol AppPasswordHasher: Sendable {
  func hash(_ password: String) async throws -> String
  
  func verify(_ password: String, _ hashedPassword: String) async throws -> Bool
  
}

protocol UserRepo: Sendable {

  func create(email: String, password: String) async throws -> User

  func getEmailMethod(_ email: String) async throws -> UserEmailMethod?
}
