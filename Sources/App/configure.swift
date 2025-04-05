import SharedBackend
import Vapor

public func configure(_ app: Application) async throws {

  app.http.server.configuration.port = 3000
  app.middleware.use(RepoErrorMiddleware())
  
  try configureEmail(app)
  
  app.mongoDatabases = [:]

  let appUtils = AppUtils(app)

  try appUtils.configureCors()
  appUtils.setCompanyStandardJSONEncoderDecoder()
  try await appUtils.configurePrivateKey()

  // register routes
  try routes(app)
}

func configureEmail(_ app: Application) throws {
  // TODO: migrate to AWS Simple Email Service

  guard let SENDGRID_API_KEY = Environment.get("SENDGRID_API_KEY") else {
    throw RuntimeError("SENDGRID_API_KEY not defined")
  }

  // email configuration
  app.sendGridConfiguration = .init(apiKey: SENDGRID_API_KEY)
}
