import JWT
import Utils
import Vapor

extension Application {
  func setJWTKeyFromEnv(name: String, kid: String) async throws {
    guard let oneLinePrivateKeyString = Environment.get(name) else {
      throw RuntimeError("\(name) not defined")
    }
    let privateKeyString = oneLinePrivateKeyString.replacingOccurrences(of: "\\n", with: "\n")

    // ECDSA - es256
    let privateKey = try ES256PrivateKey(pem: privateKeyString)

    await self.jwt.keys.add(ecdsa: privateKey, kid: JWKIdentifier(string: kid))
  }
}
