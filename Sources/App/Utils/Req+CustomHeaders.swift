import SharedBackend
import Vapor

extension Request {
  var poolId: String? {
    self.headers.first(name: "x-pool-id")
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
