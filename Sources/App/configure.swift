import SharedBackend
import Vapor

let SECRET_KEY = Environment.get("SECRET_KEY")
let REFRESH_KEY = Environment.get("REFRESH_KEY")
let SENDGRID_API_KEY = Environment.get("SENDGRID_API_KEY")

enum EnvironmentValueError: Error {
  case undefined(String)
}

public func configure(_ app: Application) async throws {
  guard let SECRET_KEY else {
    throw EnvironmentValueError.undefined("SECRET_KEY")
  }
  guard let REFRESH_KEY else {
    throw EnvironmentValueError.undefined("REFRESH_KEY")
  }

  guard let SENDGRID_API_KEY else {
    throw RuntimeError("SENDGRID_API_KEY not defined")
  }

  app.http.server.configuration.port = 3000

  let corsConfiguration = CORSMiddleware.Configuration(
    // TODO: origin should change on prod or qa
    allowedOrigin: .any(["http://localhost:4000"]),
    allowedMethods: [.GET, .POST, .PUT, .OPTIONS, .DELETE, .PATCH],
    allowedHeaders: [
      .accept, .authorization, .contentType, .origin, .xRequestedWith, .userAgent,
      .accessControlAllowOrigin, .setCookie, .setCookie2,
    ],
    allowCredentials: true
  )
  let cors = CORSMiddleware(configuration: corsConfiguration)
  // cors middleware should come before default error middleware using `at: .beginning`
  app.middleware.use(cors, at: .beginning)

  app.middleware.use(RepoErrorMiddleware())

  // email configuration
  app.sendGridConfiguration = .init(apiKey: SENDGRID_API_KEY)

  setVaporWithCompanyStandardJSONEncoderDecoder()

  // settign the JWT keys
  app.jwt.signers.use(.hs256(key: SECRET_KEY), kid: "secret", isDefault: true)
  app.jwt.signers.use(.hs256(key: REFRESH_KEY), kid: "refresh")
  // TODO: use RS256 key

  // register routes
  try routes(app)
}
