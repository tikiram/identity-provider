import Fluent
import Vapor

final class Session: Model, @unchecked Sendable {
    static let schema = "session"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "refresh_token")
    var refreshToken: String

    @Parent(key: "user_id")
    var user: User

    init() {}

    init(refreshToken: String, userID: User.IDValue) {
        self.refreshToken = refreshToken
        $user.id = userID
    }
}
