import JWT
import SharedBackend
import Vapor

extension Application {
  func setMasterPoolKey() async throws {
    let poolConfig = try getPoolConfig()
    try await setJWTKeyFromEnv(name: "MASTER_POOL_PRIVATE_KEY", kid: poolConfig.rootPoolKid)
  }
}
