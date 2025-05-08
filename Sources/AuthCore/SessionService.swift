import Foundation

public class SessionService {

  private let sessionRepo: SessionRepo
  private let tokenManager: TokenManager
  private let simpleHasher: SimpleHasher

  public init(
    _ sessionRepo: SessionRepo,
    _ tokenManager: TokenManager,
    _ simpleHashser: SimpleHasher
  ) {
    self.sessionRepo = sessionRepo
    self.tokenManager = tokenManager
    self.simpleHasher = simpleHashser
  }

  func create(_ user: User) async throws -> Tokens {
    let sessionId = UUID().uuidString

    let tokens = try await tokenManager.buildTokens(user, sessionId: sessionId)

    try await self.sessionRepo.save(
      userId: user.id,
      sessionId: sessionId,
      refreshTokenHash: simpleHasher.hash(tokens.refreshTokenInfo.value)
    )

    return tokens
  }

  func renew(refreshToken: String) async throws -> Tokens {
    // TODO: detect stolen refreshToken
    // https://stackoverflow.com/questions/59511628/is-it-secure-to-store-a-refresh-token-in-the-database-to-issue-new-access-toke

    let newTokens = try await tokenManager.buildTokens(refreshToken)
    let payload = try await tokenManager.getPayload(refreshToken)

    try await self.sessionRepo.update(
      userId: payload.userId,
      sessionId: payload.sessionId,
      newRefreshTokenHash: simpleHasher.hash(newTokens.refreshTokenInfo.value),
      previousRefreshTokenHash: simpleHasher.hash(refreshToken)
    )

    return newTokens
  }

  func invalidate(refreshToken: String) async throws {
    let payload = try await tokenManager.getPayload(refreshToken)

    try await self.sessionRepo.invalidate(
      userId: payload.userId,
      sessionId: payload.sessionId,
      refreshTokenHash: simpleHasher.hash(refreshToken)
    )
  }

}
