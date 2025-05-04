import SharedBackend
import Vapor

struct PoolsConfig {
  let accessTokenExpirationTime: TimeInterval
  let refreshTokenExpirationTime: TimeInterval

  /// Note: do not create regular pools with this value as id
  let rootPoolKid: String
  let rootPoolAccessTokenExpirationTime: TimeInterval
  let rootPoolRefreshTokenExpirationTime: TimeInterval
}

private struct PoolsConfigKey: StorageKey {
  typealias Value = PoolsConfig
}

extension Application {
  var poolsConfig: PoolsConfig? {
    get {
      storage[PoolsConfigKey.self]
    }
    set {
      storage[PoolsConfigKey.self] = newValue
    }
  }
}

extension Application {
  func getPoolConfig() throws -> PoolsConfig {
    guard let config = self.poolsConfig else {
      throw RuntimeError("Missing master pool configuration")
    }
    return config
  }
}
