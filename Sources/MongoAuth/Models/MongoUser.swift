import AuthCore
import Foundation
import Meow

struct MongoUser: Model, User, UserEmailMethod {
  
  // User protocol
  var id: String {
    return self._id
  }
  
  // UserEmailMethod protocol
  var userId: String {
    return self._id
  }

  @Field var _id: String
  @Field var poolId: String?
  
  @Field var createdAt: Date

  @Field var email: String // Unique within a pool
  @Field var passwordHash: String
}
