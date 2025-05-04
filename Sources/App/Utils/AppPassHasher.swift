import Vapor
import AuthCore

extension AsyncPasswordHasher: PassHasher {
  public func verify(_ password: String, _ hashedPassword: String) async throws -> Bool {
    return try await self.verify(password, created: hashedPassword)
  }
}
