
import Vapor

struct TokensPayload: Content {
    let grand_type: String
    let username: String?
    let password: String?
    let refresh_token: String?
}

struct TokensResponse: Content {
    let access_token: String
    let refresh_token: String?
    let expires_in: Double?
}

struct SignUpPayload: Content {
    let username: String
    let password: String
}

struct AuthControler: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let router = routes.grouped("auth")

        router.post("register", use: register)
        router.post("token", use: token)
    }

    func register(req: Request) async throws -> HTTPStatus {
        // try SignUpPayload.validate(content: req)
        let payload = try req.content.decode(SignUpPayload.self)

        try await Auth(req).register(
            email: payload.username,
            password: payload.password
        )

        return .noContent
    }

    func token(req: Request) async throws -> TokensResponse {
        let payload = try req.content.decode(TokensPayload.self)

        if payload.grand_type == "password" {
            guard let email = payload.username,
                  let password = payload.password
            else {
                throw Abort(.badRequest, reason: "email and password required")
            }

            let tokens = try await Auth(req).authenticate(email, password)

            return TokensResponse(
                access_token: tokens.accessToken,
                refresh_token: tokens.refreshToken,
                expires_in: ACCESS_TOKEN_EXPIRATION
            )
        }

        if payload.grand_type == "refresh_token" {
            guard let refreshToken = payload.refresh_token else {
                throw Abort(.badRequest, reason: "refresh_token required")
            }

            let accessToken = try await Auth(req)
                .getNewAccessToken(refreshToken: refreshToken)
            return TokensResponse(
                access_token: accessToken,
                refresh_token: nil,
                expires_in: ACCESS_TOKEN_EXPIRATION
            )
        }

        throw Abort(.badRequest, reason: "Not supported")
    }
}
