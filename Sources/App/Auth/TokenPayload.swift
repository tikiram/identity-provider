
import JWT
import Vapor

struct TokenPayload: JWTPayload {
    var subject: SubjectClaim
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

