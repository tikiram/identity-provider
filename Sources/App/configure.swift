import SharedBackend
import Vapor

let SENDGRID_API_KEY = Environment.get("SENDGRID_API_KEY")

enum EnvironmentValueError: Error {
  case undefined(String)
}

public func configure(_ app: Application) async throws {

  let appUtils = AppUtils(app)

  guard let SENDGRID_API_KEY else {
    throw RuntimeError("SENDGRID_API_KEY not defined")
  }

  app.http.server.configuration.port = 3000

  try appUtils.configureCors()

  app.middleware.use(RepoErrorMiddleware())

  // email configuration
  app.sendGridConfiguration = .init(apiKey: SENDGRID_API_KEY)

  appUtils.setCompanyStandardJSONEncoderDecoder()

  try appUtils.configurePrivateKey()

  // register routes
  try routes(app)
}
