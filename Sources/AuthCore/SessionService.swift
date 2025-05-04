import Foundation

public class SessionService {

  private let sessionRepo: SessionRepo
  private let tokenManager: TokenManager

  public init(
    _ sessionRepo: SessionRepo,
    _ tokenManager: TokenManager
  ) {
    self.sessionRepo = sessionRepo
    self.tokenManager = tokenManager
  }

  func create(_ user: User) async throws -> Tokens {
    let sessionId = UUID().uuidString

    let tokens = try await tokenManager.buildTokens(user, sessionId: sessionId)

    try await self.sessionRepo.save(
      userId: user.id,
      sessionId: sessionId,
      refreshToken: tokens.refreshTokenInfo.value
    )

    return tokens
  }

  func renew(refreshToken: String) async throws -> Tokens {
    // TODO: detect stolen refreshToken
    // https://stackoverflow.com/questions/59511628/is-it-secure-to-store-a-refresh-token-in-the-database-to-issue-new-access-toke

    let tokens = try await tokenManager.buildTokens(refreshToken)
    let payload = try await tokenManager.getPayload(refreshToken)

    try await self.sessionRepo.update(
      sessionId: payload.sessionId,
      newRefreshToken: tokens.refreshTokenInfo.value,
      previousRefreshToken: refreshToken
    )

    return tokens
  }

  func invalidate(refreshToken: String) async throws {
    let payload = try await tokenManager.getPayload(refreshToken)

    try await self.sessionRepo.invalidate(
      sessionId: payload.sessionId,
      refreshToken: refreshToken
    )
  }

}
