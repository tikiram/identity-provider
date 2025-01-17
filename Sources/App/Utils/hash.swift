import CryptoKit
import Foundation

func generateSHA256(from input: String) -> String {
  let inputData = Data(input.utf8)
  let hashed = SHA256.hash(data: inputData)
  return hashed.compactMap { String(format: "%02x", $0) }.joined()
}
