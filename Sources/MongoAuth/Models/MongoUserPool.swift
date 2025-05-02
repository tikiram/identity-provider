import AuthCore
import Foundation
import Meow

struct MongoUserPool: Model {

  @Field var _id: ObjectId

  @Field var userId: String
  @Field var poolId: String

  // granular permissions
  //@Field var permissions: [String]

}
