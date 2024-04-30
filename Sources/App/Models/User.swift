import Fluent
import Vapor

final class User: Model, Content {
    static let schema = "user"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "email")
    var email: String

    @Field(key: "password_hash")
    var passwordHash: String

    init() {}

    init(
        id: UUID? = nil,
        email: String,
        passwordHash: String
    ) {
        self.id = id
        self.email = email
        self.passwordHash = passwordHash
    }
}

// TODO: move this to other place?
extension User: ModelAuthenticatable {

    static let usernameKey = \User.$email
    static let passwordHashKey = \User.$passwordHash

    func verify(password: String) throws -> Bool {
        try Bcrypt.verify(password, created: passwordHash)
    }
}
