import SharedBackend
import Vapor

private let masterPoolName = "master"

extension Request {
  var poolId: String {
    let value = self.headers.first(name: "x-pool-id") ?? ""

    guard !value.isEmpty else {
      return masterPoolName
    }

    return value
  }
}

extension Request {
  var clientType: ClientType {
    get throws {
      switch self.headers.first(name: "x-client-type") {
      case "web":
        return .web
      case "mobile":
        return .mobile
      case "service":
        return .service
      default:
        throw RuntimeError("unknown_client_type")
      }
    }
  }
}
