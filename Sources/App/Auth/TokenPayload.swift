
import JWT
import Vapor

struct TokenPayload: JWTPayload {
    let subject: SubjectClaim
    let expiration: ExpirationClaim

    var userId: UUID {
        UUID(uuidString: subject.value)!
    }
    
    enum CodingKeys: String, CodingKey {
        case subject = "sub"
        case expiration = "exp"
    }

    init(user: User, duration: TimeInterval) {
        subject = SubjectClaim(value: user.id!.uuidString)
        expiration = ExpirationClaim(value: Date().addingTimeInterval(duration))
    }

    func verify(using _: JWTKit.JWTSigner) throws {
        try expiration.verifyNotExpired()
    }
}
