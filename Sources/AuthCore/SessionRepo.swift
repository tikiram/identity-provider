public enum SessionRepoError: Error {
  case tokenOutOfSync
  case unexpectedError(String)
}

public protocol SimpleHasher {
  func hash(_ input: String) -> String
}

public protocol SessionRepo {

  func save(
    userId: String,
    sessionId: String,
    refreshTokenHash: String
  ) async throws

  func update(
    userId: String,
    sessionId: String,
    newRefreshTokenHash: String,
    previousRefreshTokenHash: String
  ) async throws

  func invalidate(
    userId: String,
    sessionId: String,
    refreshTokenHash: String
  ) async throws

}
