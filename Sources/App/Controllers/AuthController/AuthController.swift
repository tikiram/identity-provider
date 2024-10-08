import Vapor

struct AuthControler: RouteCollection {
  func boot(routes: RoutesBuilder) throws {
    let router = routes.grouped("auth")

    router.post("register", use: { try await register(req: $0) })
    router.post("token", use: { try await tokenHandler($0) })
    router.post("logout", use: { try await logout($0) })
    router.post("reset", use: { try await resetPassword($0) })
  }

  func register(req: Request) async throws -> TokensResponse {
    try SignUpPayload.validate(content: req)
    let payload = try req.content.decode(SignUpPayload.self)

    let tokens = try await Auth(req)
      .register(
        email: payload.username,
        password: payload.password
      )

    return TokensResponse(tokens: tokens, expiresIn: Auth.accessTokenExpirationTime)
  }

  func logout(_ req: Request) async throws -> HTTPStatus {

    try RefreshTokenGrandTypePayload.validate(content: req)
    let payload = try req.content.decode(RefreshTokenGrandTypePayload.self)

    try await Auth(req)
      .logout(refreshToken: payload.refreshToken)

    return .noContent
  }

  func resetPassword(_ req: Request) async throws -> HTTPStatus {

    try await Auth(req)
      .sendResetCode(email: "test@test.com")

    return .noContent
  }

  private func tokenHandler(_ req: Request) async throws -> TokensResponse {
    try TokensPayload.validate(content: req)
    let tokensPayload = try req.content.decode(TokensPayload.self)
    switch tokensPayload.grandType {
    case .password:
      return try await passwordGrandTypeHandler(req)
    case .refreshToken:
      return try await refreshTokenGrandTypeHandler(req)
    }
  }

  private func passwordGrandTypeHandler(_ req: Request) async throws -> TokensResponse {
    try PasswordGrandTypePayload.validate(content: req)
    let payload = try req.content.decode(PasswordGrandTypePayload.self)

    guard let password = payload.password else {
      throw Abort(.badRequest, reason: "Missing password")
    }

    let tokens = try await Auth(req)
      .authenticate(email: payload.username, password: password)

    return TokensResponse(tokens: tokens, expiresIn: Auth.accessTokenExpirationTime)
  }

  private func refreshTokenGrandTypeHandler(_ req: Request) async throws -> TokensResponse {
    try RefreshTokenGrandTypePayload.validate(content: req)
    let payload = try req.content.decode(RefreshTokenGrandTypePayload.self)

    let accessToken = try await Auth(req)
      .getNewAccessToken(refreshToken: payload.refreshToken)

    return TokensResponse(
      accessToken: accessToken,
      expiresIn: Auth.accessTokenExpirationTime
    )
  }
}
