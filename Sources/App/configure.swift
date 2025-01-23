import SharedBackend
import Vapor
import JWTKit

let PRIVATE_KEY_STRING = Environment.get("PRIVATE_KEY_STRING")
let SENDGRID_API_KEY = Environment.get("SENDGRID_API_KEY")

enum EnvironmentValueError: Error {
  case undefined(String)
}

public func configure(_ app: Application) async throws {
  guard let PRIVATE_KEY_STRING else {
    throw EnvironmentValueError.undefined("PRIVATE_KEY")
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
  
  let pkey=PRIVATE_KEY_STRING.replacingOccurrences(of: "\\n", with: "\n")
  
  let privateKey = try ECDSAKey.private(pem: pkey)

  app.jwt.signers.use(.es256(key: privateKey), kid: "private", isDefault: true)

  // register routes
  try routes(app)
}
