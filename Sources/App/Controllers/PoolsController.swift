import Vapor

struct PoolsControler: RouteCollection {

  func boot(routes: RoutesBuilder) throws {
    let pools = routes.grouped("pools")
    pools.post(use: create)
  }

  private struct CreatePayload: Content, Validatable {
    let kid: String
    let privateKey: String
    let publicKey: String

    static func validations(_ validations: inout Validations) {
      validations.add("kid", as: String.self, is: !.empty)
      validations.add("privateKey", as: String.self, is: !.empty)
      validations.add("publicKey", as: String.self, is: !.empty)
    }
  }
  @Sendable
  func create(req: Request) async throws -> HTTPStatus {
    try CreatePayload.validate(content: req)
    let payload = try req.content.decode(CreatePayload.self)

    let userPoolService = try req.getUserPoolService()

    try await userPoolService.create(payload.kid, payload.privateKey, payload.publicKey)

    // TODO: add key to the local keys storage
    //req.application.jwt.keys.add(ecdsa: ECDSAKey)

    return .noContent
  }
}
