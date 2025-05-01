import Vapor

struct PoolsControler: RouteCollection {

  func boot(routes: RoutesBuilder) throws {

    let todos = routes.grouped("pools")
    //todos.get(use: index)
    todos.post(use: create)

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
  func create(req: Request) async throws -> Response {
    try CreatePayload.validate(content: req)
    let payload = try req.content.decode(CreatePayload.self)

    //    let auth = try req.bAuth()

    //let tokens = try await auth.register(payload.email, payload.password)

    let response = Response()

    return response
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
