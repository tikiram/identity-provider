import AuthCore
import Vapor

struct AuthControler: RouteCollection, Sendable {

  private let authSelector: @Sendable (_ req: Request) throws -> Auth

  init(authSelector: @Sendable @escaping (_ req: Request) throws -> Auth) {
    self.authSelector = authSelector
  }

  func boot(routes: RoutesBuilder) throws {
    let auth = routes.grouped("auth")
    auth.post("register", use: self.register)
    auth.post("login", use: self.signIn)
    auth.post("logout", use: self.logout)
    auth.post("refresh", use: self.refresh)
  }

  private struct SignUpPayload: Content, Validatable {
    let email: String
    let password: String

    static func validations(_ validations: inout Validations) {
      validations.add("email", as: String.self, is: .email)
      validations.add("password", as: String.self, is: !.empty)
    }
  }
  @Sendable
  func register(req: Request) async throws -> Response {
    try SignUpPayload.validate(content: req)
    let payload = try req.content.decode(SignUpPayload.self)

    let auth = try self.authSelector(req)

    let (user, tokens) = try await auth.register(payload.email, payload.password)

    let response = Response()
    try response.handlePayload(req.clientType, user: user, tokens: tokens)
    return response
  }

  private struct SignInPayload: Content, Validatable {
    let email: String
    let password: String

    static func validations(_ validations: inout Validations) {
      validations.add("email", as: String.self, is: .email)
      validations.add("password", as: String.self, is: !.empty)
    }
  }
  @Sendable
  func signIn(req: Request) async throws -> Response {
    try SignInPayload.validate(content: req)
    let payload = try req.content.decode(SignInPayload.self)

    let auth = try self.authSelector(req)

    let (user, tokens) = try await auth.login(payload.email, payload.password)

    let response = Response()
    try response.handlePayload(req.clientType, user: user, tokens: tokens)
    return response
  }

  @Sendable
  func logout(_ req: Request) async throws -> Response {
    let refreshToken = try req.getRefreshToken()

    let auth = try self.authSelector(req)

    try await auth.logout(refreshToken)

    let response = Response(status: .noContent)
    response.removeRefreshTokenCookie()
    return response
  }

  @Sendable
  func refresh(_ req: Request) async throws -> Response {
    let refreshToken = try req.getRefreshToken()

    let auth = try self.authSelector(req)

    let tokens = try await auth.refreshToken(refreshToken)

    let response = Response()
    try response.handlePayload(req.clientType, tokens: tokens)
    return response

  }
}

private struct RefreshPayload: Content, Validatable {
  let refreshToken: String

  static func validations(_ validations: inout Validations) {
    validations.add("refreshToken", as: String.self, is: !.empty)
  }
}

extension Request {
  fileprivate func getRefreshToken() throws -> String {
    switch try self.clientType {
    case .web:
      return try self.getRefreshTokenFromCookie()
    case .mobile, .service:
      try RefreshPayload.validate(content: self)
      let payload = try self.content.decode(RefreshPayload.self)
      return payload.refreshToken
    }
  }
}
