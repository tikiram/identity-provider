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

    let auth = try req.bAuth()

    let (user, tokens) = try await auth.login(payload.email, payload.password)

    let response = Response()
    try response.handlePayload(req.clientType, user: user, tokens: tokens)
    return response
  }

  private struct LogoutPayload: Content, Validatable {
    let refreshToken: String

    static func validations(_ validations: inout Validations) {
      validations.add("refreshToken", as: String.self, is: !.empty)
    }
  }
  @Sendable
  func logout(_ req: Request) async throws -> Response {
    try LogoutPayload.validate(content: req)
    let payload = try req.content.decode(LogoutPayload.self)

    let auth = try req.bAuth()

    try await auth.logout(payload.refreshToken)

    let response = Response(status: .noContent)
    response.removeRefreshTokenCookie()
    return response
  }

  private struct RefreshPayload: Content, Validatable {
    let refreshToken: String

    static func validations(_ validations: inout Validations) {
      validations.add("refreshToken", as: String.self, is: !.empty)
    }
  }
  @Sendable
  func refresh(_ req: Request) async throws -> Response {
    try RefreshPayload.validate(content: req)
    let payload = try req.content.decode(RefreshPayload.self)

    let auth = try req.bAuth()

    let tokens = try await auth.refreshToken(payload.refreshToken)

    let response = Response()
    try response.handlePayload(req.clientType, tokens: tokens)
    return response

  }

}
