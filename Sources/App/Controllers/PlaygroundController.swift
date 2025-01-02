import Fluent
import Vapor

struct PlaygroundController: RouteCollection {
  func boot(routes: RoutesBuilder) throws {
    let playground = routes.grouped("playground")

    playground.get(use: { try await get(req: $0) })
  }

  func get(req: Request) async throws -> HTTPStatus {
    
    try await something()
    
    return .noContent

  }
}
