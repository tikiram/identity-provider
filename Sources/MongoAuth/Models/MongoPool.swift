import AuthCore
import Foundation
import Meow

struct MongoPool: Model, Pool {

  var id: String {
    return _id
  }

  @Field var _id: String
  
  /// Original creator of the pool
  @Field var createdBy: String

  @Field var encryptedPrivateKey: String
  @Field var encryptedPublicKey: String
  @Field var createdAt: Date

}
