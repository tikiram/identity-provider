public protocol DataCipher {
  func encrypt(_ message: String) -> String
  func decrypt(_ encryptedMessage: String) -> String
}
