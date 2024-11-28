import Fluent
import Vapor

func routes(_ app: Application) throws {
  app.get { _ async in
    "It works!"
  }

  app.get("hello") { _ async -> String in
    "Hello, world!"
  }

  //  try app.grouped(app.sessions.middleware).register(collection: AuthControler())
  try app.register(collection: AuthControler())

  let secure =
    app
    .grouped(
      TokenPayload.authenticator(),
      TokenPayload.guardMiddleware()
    )

  secure.get("info") { req -> TokenPayload in
    let payload = try req.auth.require(TokenPayload.self)
    return payload
  }
}
