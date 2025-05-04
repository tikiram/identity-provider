import AuthCore
// Swift Crypto is an open-source implementation of a substantial portion of the API of
// Apple CryptoKit suitable for use on Linux platforms. It enables cross-platform or server
// applications with the advantages of CryptoKit.
import Crypto
import Foundation

final class AppSimpleHasher: SimpleHasher {
  func hash(_ input: String) -> String {
    return generateSHA256(from: input)
  }
}

private func generateSHA256(from input: String) -> String {
  let inputData = Data(input.utf8)
  let hashed = SHA256.hash(data: inputData)
  return hashed.compactMap { String(format: "%02x", $0) }.joined()
}
