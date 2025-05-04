import Foundation
import Meow

struct MongoSession: Model {

  var id: String {
    return self._id.description
  }

  @Field var _id: String

  @Field var userId: String

  @Field var refreshTokenHash: String
  @Field var createdAt: Date
  @Field var lastAccessedAt: Date
  @Field var loggedOutAt: Date?
}
