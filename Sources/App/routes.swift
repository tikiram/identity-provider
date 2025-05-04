import Vapor

func routes(_ app: Application) throws {
  app.get { _ async in
    "It works!"
  }

  app.get("hello") { _ async -> String in
    "Hello, world!"
  }

  try app.group("b") { b in
    try b.group("v1") { v1 in
      try v1.register(collection: BAuthControler())

      let secure = v1.grouped(
        AppTokenPayload.authenticator(),
        AppTokenPayload.guardMiddleware())

      try secure.register(collection: PoolsControler())
    }
  }

  let secure =
    app
    .grouped(
      AppTokenPayload.authenticator(),
      AppTokenPayload.guardMiddleware()
    )

  secure.get("info") { req -> AppTokenPayload in
    let payload = try req.auth.require(AppTokenPayload.self)
    return payload
  }
}
