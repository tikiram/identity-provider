
import Foundation
import Meow


struct MongoDBUser: Model, User {
  public static let collectionName: String = "users"
  
  var id: String {
    return self._id
  }
  
  @Field var _id: String
  @Field var createdAt: Date
  
  @Field var roles: [String]
  
  @Field var email: String
  @Field var passwordHash: String
}
