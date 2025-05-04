public enum UserServiceError: Error {
  case invalidCredentials
}

public class UserService {

  private let userRepo: UserRepo
  private let passHasher: PassHasher

  public init(
    _ userRepo: UserRepo,
    _ appPasswordHasher: PassHasher
  ) {
    self.userRepo = userRepo
    self.passHasher = appPasswordHasher
  }

  func create(_ email: String, _ password: String) async throws -> User {
    let hash = try await passHasher.hash(password)

    let user = try await userRepo.create(email: email, passwordHash: hash)
    return user
  }

  func authenticate(_ email: String, _ password: String) async throws -> User {
    let userEmailMethod = try await userRepo.getEmailMethod(email)
    guard let userEmailMethod else {
      throw UserServiceError.invalidCredentials
    }

    let sameHash = try await passHasher.verify(password, userEmailMethod.passwordHash)

    guard sameHash else {
      // TODO: block user for certain amount of time after 3 attempts
      throw UserServiceError.invalidCredentials
    }

    let user = try await userRepo.getUser(userId: userEmailMethod.userId)

    return user
  }

}
