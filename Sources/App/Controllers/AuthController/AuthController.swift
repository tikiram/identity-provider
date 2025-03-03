import Vapor

struct AuthControler: RouteCollection {
  func boot(routes: RoutesBuilder) throws {
    let router = routes.grouped("auth")

    router.post("register", use: { try await register(req: $0) })
    router.post("token", use: { try await tokenHandler($0) })
    router.post("logout", use: { try await logout($0) })
    router.post("reset", use: { try await resetPassword($0) })
  }

  func register(req: Request) async throws -> Response {
    try SignUpPayload.validate(content: req)
    let payload = try req.content.decode(SignUpPayload.self)

    let tokens = try await Auth(req)
      .register(
        email: payload.username,
        password: payload.password
      )

    return try handleTokens(req, tokens)
  }

  func logout(_ req: Request) async throws -> Response {

    // try RefreshTokenGrantTypePayload.validate(content: req)
    // let payload = try req.content.decode(RefreshTokenGrantTypePayload.self)

    guard let refreshTokenCookie = req.cookies[REFRESH_TOKEN_COOKIE_NAME] else {
      throw Abort(.unauthorized, reason: "Missing refresh token")
    }

    try await Auth(req)
      .logout(refreshTokenCookie.string)

    let response = Response(status: .noContent)
    AuthResponseManager(response)
      .setRefreshTokenCookie("", expirationTime: 0)

    return response
  }

  func resetPassword(_ req: Request) async throws -> HTTPStatus {
    try ResetPasswordPayload.validate(content: req)
    let payload = try req.content.decode(ResetPasswordPayload.self)

    // TODO: get actual payload

    try await Auth(req)
      .sendResetCode(email: payload.email)

    return .noContent
  }

  private func tokenHandler(_ req: Request) async throws -> Response {
    try TokensPayload.validate(content: req)
    let tokensPayload = try req.content.decode(TokensPayload.self)

    print(tokensPayload.grantType)
    switch tokensPayload.grantType {
    case .password:
      return try await passwordGrandTypeHandler(req)
    case .refreshToken:
      return try await refreshTokenGrandTypeHandler(req)
    }
  }

  private func passwordGrandTypeHandler(_ req: Request) async throws -> Response {
    try PasswordGrantTypePayload.validate(content: req)
    let payload = try req.content.decode(PasswordGrantTypePayload.self)

    guard let password = payload.password else {
      throw Abort(.badRequest, reason: "Missing password")
    }

    let tokens = try await Auth(req)
      .authenticate(email: payload.username, password: password)

    return try handleTokens(req, tokens)
  }

  // TODO: find a better name
  private func handleTokens(_ req: Request, _ tokens: Tokens) throws -> Response {

    // TODO: this cookie should only be created with web apps

    let tokensResponse = TokensResponse(tokens: tokens, expiresIn: Auth.accessTokenExpirationTime)

    let response = Response()
    try response.content.encode(tokensResponse, as: .json)

    AuthResponseManager(response)
      .setRefreshTokenCookie(tokens.refreshToken, expirationTime: Auth.refreshTokenExpirationTime)

    return response
  }

  private func refreshTokenGrandTypeHandler(_ req: Request) async throws -> Response {
    guard let refreshTokenCookie = req.cookies[REFRESH_TOKEN_COOKIE_NAME] else {
      throw Abort(.unauthorized, reason: "Missing refresh token")
      // TODO: use this instead
      // throw Abort(.badRequest, reason: "MISSING_REFRESH_TOKEN")
    }

    let tokens = try await Auth(req)
      .rotateTokens(refreshTokenCookie.string)

    return try handleTokens(req, tokens)
  }
}

struct GenericErrorPayload: Codable {
  let reason: String
}
