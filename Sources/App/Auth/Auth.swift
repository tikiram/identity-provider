
import Fluent
import PostgresNIO
import Vapor

struct Tokens {
    let accessToken: String
    let refreshToken: String
}

let ACCESS_TOKEN_EXPIRATION: TimeInterval = 60 * 60 // 1h
let REFRESH_TOKEN_EXPIRATION: TimeInterval = 60 * 60 * 24 // 1d

enum AuthError: Error {
    case notValidToken
    case emailAlreadyUsed
    case invalidCredentials
}

class Auth {
    private let request: Request

    init(_ request: Request) {
        self.request = request
    }

    func register(email: String, password: String) async throws {
        let user = try User(
            email: email,
            passwordHash: Bcrypt.hash(password)
        )

        do {
            try await user.save(on: request.db)
        } catch let error as PSQLError {
            if error.isConstraintFailure {
                throw AuthError.emailAlreadyUsed
            }
            throw error
        }
    }

    func authenticate(_ email: String,
                      _ password: String) async throws -> Tokens
    {
        let user = try await User.query(on: request.db)
            .filter(\.$email == email)
            .first()

        guard let user else {
            throw AuthError.invalidCredentials
        }

        let sameHash = try Bcrypt.verify(password, created: user.passwordHash)

        guard sameHash else {
            throw AuthError.invalidCredentials
        }

        let accessToken = try createAccessToken(user)
        let refreshToken = try createRefreshToken(user)
        try await storeRefreshToken(refreshToken, userId: user.requireID())
        return Tokens(accessToken: accessToken, refreshToken: refreshToken)
    }

    func getNewAccessToken(refreshToken: String) async throws -> String {
        let foundSession = try await Session.query(on: request.db)
            .with(\.$user)
            .filter(\.$refreshToken == refreshToken)
            .first()
        
        // TODO: validate token is not expired

        guard let session = foundSession else {
            throw AuthError.notValidToken
        }

        let accessToken = try createAccessToken(session.user)

        return accessToken
    }

    private func createAccessToken(_ user: User) throws -> String {
        let payload = TokenPayload(
            user: user,
            duration: ACCESS_TOKEN_EXPIRATION
        )
        let token = try request.jwt.sign(payload)
        return token
    }

    private func createRefreshToken(_ user: User) throws -> String {
        let refreshPayload = TokenPayload(
            user: user,
            duration: REFRESH_TOKEN_EXPIRATION
        )
        let refreshToken = try request.jwt.sign(refreshPayload, kid: "refresh")
        return refreshToken
    }

    private func storeRefreshToken(
        _ refreshToken: String,
        userId: User.IDValue
    ) async throws {
        let session = Session(refreshToken: refreshToken, userID: userId)
        try await session.save(on: request.db)
    }
}
