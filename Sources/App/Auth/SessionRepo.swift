enum SessionRepoError: Error {
  case tokenOutOfSync
  case unexpectedError(String)
}

protocol SessionRepo {

  func save(
    userId: String,
    sessionSubId: String,
    refreshToken: String
  ) async throws

  func update(
    userId: String,
    sessionSubId: String,
    newRefreshToken: String,
    previousRefreshToken: String
  ) async throws

  func invalidate(
    userId: String,
    sessionSubId: String,
    refreshToken: String
  ) async throws

}
