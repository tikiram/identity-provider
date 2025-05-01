//import Vapor
//
//struct RepoErrorMiddleware: AsyncMiddleware {
//  func respond(to request: Request, chainingTo next: AsyncResponder) async throws -> Response {
//
//    // TODO: check http codes related to invalid tokens
//    
//    do {
//      return try await next.respond(to: request)
//    } catch let error as SessionRepoError {
//      switch error {
//      case .tokenOutOfSync:
//        throw Abort(.unauthorized, reason: "TOKEN_OUT_OF_SYNC")
//      case .unexpectedError(let description):
//        throw Abort(.internalServerError, reason: description)
//
//      }
//    }
//    catch let error as AuthError {
//      switch error {
//      case .emailAlreadyUsed:
//        throw Abort(.badRequest, reason: "EMAIL_ALREADY_USED")
//      case .invalidCredentials:
//        throw Abort(.unauthorized, reason: "INVALID_CREDENTIALS")
//      case .tokenNotFound:
//        throw Abort(.unauthorized, reason: "INVALID_TOKEN")
//      case .userHasNoPassword:
//        throw Abort(.unauthorized, reason: "USER_HAS_NO_PASSWORD")
//      case .jwtError(_):
//        throw error
//      }
//    } catch {
//      print(error)
//      throw error
//    }
//  }
//}
