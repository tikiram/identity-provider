
import JWT
import Vapor

struct TokenPayload: JWTPayload, Authenticatable, Content {
    enum CodingKeys: String, CodingKey {
        case subject = "sub"
        case expiration = "exp"
    }

    let subject: SubjectClaim
    let expiration: ExpirationClaim

    var userId: UUID {
        UUID(uuidString: subject.value)!
    }

    init(user: User, duration: TimeInterval) {
        subject = SubjectClaim(value: user.id!.uuidString)
        expiration = ExpirationClaim(value: Date().addingTimeInterval(duration))
    }

    func verify(using _: JWTKit.JWTSigner) throws {
        try expiration.verifyNotExpired()
    }
}
