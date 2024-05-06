
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
    
    
    private func tokenHandler(_ req: Request) async throws -> TokensResponse {
        let payload = try req.content.decode(TokensPayload.self)

        if payload.grand_type == "password" {
            guard let email = payload.username,
                  let password = payload.password
            else {
                throw Abort(.badRequest, reason: "EMAIL_AND_PASSWORD_REQUIRED")
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
                throw Abort(.badRequest, reason: "REFRESH_TOKEN_REQUIRED")
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
    

    func token(req: Request) async throws -> TokensResponse {

        do {
            return try await tokenHandler(req)
        }
        catch let error as AuthError {
            switch error {
            case .emailAlreadyUsed:
                throw Abort(.badRequest, reason: "EMAIL_ALREADY_USED")
            case .invalidCredentials:
                throw Abort(.badRequest, reason: "INVALID_CREDENTIALS")
            case .notValidToken:
                throw Abort(.badRequest, reason: "NOT_VALID_TOKEN")
            }
        }
    }
}
