import Vapor

struct BAuthControler: RouteCollection {

  func boot(routes: RoutesBuilder) throws {
    let auth = routes.grouped("auth")
    auth.post("register", use: self.register)
  }

  private struct BSignUpPayload: Content, Validatable {
    let email: String
    let password: String

    static func validations(_ validations: inout Validations) {
      validations.add("email", as: String.self, is: .email)
      validations.add("password", as: String.self, is: !.empty)
    }
  }
  @Sendable
  func register(req: Request) async throws -> Response {
    try BSignUpPayload.validate(content: req)
    let payload = try req.content.decode(BSignUpPayload.self)

    // TODO: I can change this method to take a parameter
    let auth = try req.bAuth()

    let tokens = try await auth.register(payload.email, payload.password)

    let response = Response()

    switch try req.clientType {
    case .web:
      let responseContent = LiteTokensResponse(
        accessToken: tokens.accessTokenInfo.value,
        expiresIn: tokens.refreshTokenInfo.expiresIn,
      )
      try response.content.encode(responseContent, as: .json)

    case .mobile, .service:
      let responseContent = TokensResponse(
        accessToken: tokens.accessTokenInfo.value,
        expiresIn: tokens.refreshTokenInfo.expiresIn,
        refreshToken: tokens.refreshTokenInfo.value,
        refreshTokenExpiresIn: tokens.refreshTokenInfo.expiresIn
      )
      try response.content.encode(responseContent, as: .json)
      response.setRefreshTokenCookie(tokens.refreshTokenInfo)
    }

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
