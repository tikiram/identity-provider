public class UserPoolService {

  private let userPoolRepo: UserPoolRepo
  private let cipher: DataCipher

  public init(
    _ userPoolRepo: UserPoolRepo,
    _ encryptor: DataCipher
  ) {
    self.userPoolRepo = userPoolRepo
    self.cipher = encryptor
  }

  public func create(_ kid: String, _ privateKey: String, _ publicKey: String) async throws {

    let encryptedPrivateKey = cipher.encrypt(privateKey)
    let encryptedPublicKey = cipher.encrypt(publicKey)

    try await userPoolRepo.create(kid, encryptedPrivateKey, encryptedPublicKey)
  }
}
