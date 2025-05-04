import Vapor

extension Request {
    func getSession() throws -> AppTokenPayload {
        return try self.auth.require(AppTokenPayload.self)
    }
}
