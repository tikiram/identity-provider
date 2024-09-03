import Vapor

struct AuthControler: RouteCollection {
  func boot(routes: RoutesBuilder) throws {
    let router = routes.grouped("auth")

    router.post("register", use: { try await register(req: $0) })
    router.post("token", use: { try await tokenHandler($0) })
  }

  func register(req: Request) async throws -> TokensResponse {
    try SignUpPayload.validate(content: req)
    let payload = try req.content.decode(SignUpPayload.self)

    let tokens = try await Auth(database: req.db, jwt: req.jwt)
      .register(
        email: payload.username,
        password: payload.password
      )
    
    return TokensResponse(tokens: tokens, expiresIn: Auth.accessTokenExpirationTime)
  }
  
  private func tokenHandler(_ req: Request) async throws -> TokensResponse {
    // TODO: validate payload
    let tokensPayload = try req.content.decode(TokensPayload.self)
    switch tokensPayload.grandType {
    case "password":
      return try await passwordGrandTypeHandler(req)
    case "refresh_token":
      return try await refreshTokenGrandTypeHandler(req)
    default:
      throw Abort(.badRequest, reason: "Not supported")
    }
  }
  
  private func passwordGrandTypeHandler(_ req: Request) async throws -> TokensResponse {
    let payload = try req.content.decode(PasswordGrandTypePayload.self)

    let tokens = try await Auth(database: req.db, jwt: req.jwt)
      .authenticate(email: payload.username, password: payload.password)

    return TokensResponse(tokens: tokens, expiresIn: Auth.accessTokenExpirationTime)
  }
  
  private func refreshTokenGrandTypeHandler(_ req: Request) async throws -> TokensResponse {
    // TODO: validate payload
    let payload = try req.content.decode(RefreshTokenGrandTypePayload.self)

    let accessToken = try await Auth(database: req.db, jwt: req.jwt)
      .getNewAccessToken(refreshToken: payload.refreshToken)
    
    return TokensResponse(
      accessToken: accessToken,
      expiresIn: Auth.accessTokenExpirationTime
    )
  }

  // TODO: create a middleware to handle these errors
//  func token(req: Request) async throws -> TokensResponse {
//    do {
//      return try await tokenHandler(req)
//    } catch let error as AuthError {
//      switch error {
//      case .emailAlreadyUsed:
//        throw Abort(.badRequest, reason: "EMAIL_ALREADY_USED")
//      case .invalidCredentials:
//        throw Abort(.badRequest, reason: "INVALID_CREDENTIALS")
//      case .notValidToken:
//        throw Abort(.unauthorized, reason: "INVALID_TOKEN")
//      }
//    }
//  }
}
