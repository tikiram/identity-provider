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
    refreshToken: String
  ) async throws

  func update(
    sessionId: String,
    newRefreshToken: String,
    previousRefreshToken: String
  ) async throws

  func invalidate(
    sessionId: String,
    refreshToken: String
  ) async throws

}
