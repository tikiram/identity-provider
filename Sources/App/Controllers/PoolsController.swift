import Vapor

struct PoolsControler: RouteCollection {

  func boot(routes: RoutesBuilder) throws {
    let pools = routes.grouped("pools")
    pools.post(use: create)
    pools.get(use: index)
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
  func create(req: Request) async throws -> String {
    try CreatePayload.validate(content: req)
    let payload = try req.content.decode(CreatePayload.self)

    let userPoolService = try req.getUserPoolService()

    try await userPoolService.create(payload.kid, payload.privateKey, payload.publicKey)

    return "prro"
  }

  @Sendable
  func index(req: Request) throws -> String {

    let payload = try req.auth.require(AppTokenPayload.self)
    print(payload)

    return "hola prro"
  }
}

private struct LiteTokensResponse: Content {
  let accessToken: String
  let expiresIn: Double
}
private struct TokensResponse: Content {
  let accessToken: String
  let expiresIn: Double
  let refreshToken: String
  let refreshTokenExpiresIn: Double
}
