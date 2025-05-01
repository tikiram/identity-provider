import Vapor

struct MasterPoolConfig {
  let accessTokenExpirationTime: TimeInterval
  let refreshTokenExpirationTime: TimeInterval
}

private struct MasterPoolConfigKey: StorageKey {
  typealias Value = MasterPoolConfig
}

extension Application {
  var masterPoolConfig: MasterPoolConfig? {
    get {
      storage[MasterPoolConfigKey.self]
    }
    set {
      storage[MasterPoolConfigKey.self] = newValue
    }
  }
}
