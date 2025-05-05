import Foundation

public class Auth {

  private let userService: UserService
  private let sessionService: SessionService

  public init(
    _ userService: UserService,
    _ sessionService: SessionService
  ) {
    self.userService = userService
    self.sessionService = sessionService
  }

  public func register(_ email: String, _ password: String) async throws -> (User, Tokens) {
    let user = try await userService.create(email, password)
    let tokens = try await sessionService.create(user)
    return (user, tokens)
  }

  public func login(_ email: String, _ password: String) async throws -> (User, Tokens) {
    let user = try await userService.authenticate(email, password)
    let tokens = try await sessionService.create(user)
    return (user, tokens)
  }

  public func refreshToken(_ refreshToken: String) async throws -> Tokens {
    return try await sessionService.renew(refreshToken: refreshToken)
  }

  public func logout(_ refreshToken: String) async throws {
    try await sessionService.invalidate(refreshToken: refreshToken)
  }

}
