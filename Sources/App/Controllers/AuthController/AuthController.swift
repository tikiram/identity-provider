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

  func logout(_ req: Request) async throws -> HTTPStatus {

    try RefreshTokenGrantTypePayload.validate(content: req)
    let payload = try req.content.decode(RefreshTokenGrantTypePayload.self)

    try await Auth(req)
      .logout(refreshToken: payload.refreshToken)

    return .noContent
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

    let cookie = getRefreshTokenCookie(value: tokens.refreshToken, expirationTime: Auth.refreshTokenExpirationTime)
    let indicatorCookie = getIndicatorCookie(cookie)
    
    response.cookies["refreshToken"] = cookie
    response.cookies["refreshTokenIndicator"] = indicatorCookie
    
    return response
  }
  
  private func getRefreshTokenCookie(value: String, expirationTime: TimeInterval) -> HTTPCookies.Value {
    let cookie = HTTPCookies.Value(
      string: value,
      expires: Date().addingTimeInterval(expirationTime),
      isSecure: true,
      isHTTPOnly: true,
      sameSite: HTTPCookies.SameSitePolicy.none
    )
    return cookie
  }
  
  private func getIndicatorCookie(_ cookie: HTTPCookies.Value) -> HTTPCookies.Value {
    // Just a cookie that can be read from JS
    let presenceCookie = HTTPCookies.Value(
      string: "true",
      expires: cookie.expires,
      isSecure: cookie.isSecure,
      isHTTPOnly: false,
      sameSite: cookie.sameSite
    )
    return presenceCookie
  }
  

  private func refreshTokenGrandTypeHandler(_ req: Request) async throws -> Response {
    
    //if let cookie = req.cookies["refreshToken"] {
    //  print(cookie.string)
    //}
    
    try RefreshTokenGrantTypePayload.validate(content: req)
    let payload = try req.content.decode(RefreshTokenGrantTypePayload.self)
    
    // TODO: we probably should rotate also the refresh token here
    // This means a new accessToken and refreshToken will be generated

    let accessToken = try await Auth(req)
      .getNewAccessToken(refreshToken: payload.refreshToken)
    
    let tokensResponse = TokensResponse(
      accessToken: accessToken,
      expiresIn: Auth.accessTokenExpirationTime
    )    
    
    // TODO: refactor this
    let response = Response()
    try response.content.encode(tokensResponse, as: .json)
    
    return response
  }
}
