public enum UserPoolRepoError: Error {
  case unexpectedError(String)
}

public protocol UserPoolRepo {

  func create(
    _ kid: String,
    _ encryptedPrivateKey: String,
    _ encryptedPublicKey: String
  ) async throws
}
