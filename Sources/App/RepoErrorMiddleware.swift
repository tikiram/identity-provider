import AuthCore
import Vapor

struct RepoErrorMiddleware: AsyncMiddleware {
  func respond(to request: Request, chainingTo next: AsyncResponder) async throws -> Response {

    do {
      return try await next.respond(to: request)
    } catch let error as SessionRepoError {
      switch error {
      case .tokenOutOfSync:
        throw Abort(.unauthorized, reason: "TOKEN_OUT_OF_SYNC")
      case .unexpectedError(let description):
        throw Abort(.internalServerError, reason: description)
      }
    } catch let error as UserRepoError {
      switch error {
      case .emailAlreadyUsed:
        throw Abort(.badRequest, reason: "EMAIL_ALREADY_USED")
      case .userNotFound:
        throw Abort(.unauthorized, reason: "INVALID_CREDENTIALS")
      case .unexpectedError(let reason):
        throw Abort(.internalServerError, reason: reason)
      }
    } catch let error as UserServiceError {
      switch error {
      case .invalidCredentials:
        throw Abort(.unauthorized, reason: "INVALID_CREDENTIALS")
      }
    } catch {
      print(error)
      throw error
    }
  }
}
