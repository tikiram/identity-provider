import Vapor

final class VaporAppPasswordHasher: AppPasswordHasher {

  private let vaporHasher: AsyncPasswordHasher
  init(_ vaporHasher: AsyncPasswordHasher) {
    self.vaporHasher = vaporHasher
  }

  func hash(_ password: String) async throws -> String {
    return try await vaporHasher.hash(password)
  }

  func verify(_ password: String, _ hashedPassword: String) async throws -> Bool {
    return try await vaporHasher.verify(password, created: hashedPassword)
  }

}
