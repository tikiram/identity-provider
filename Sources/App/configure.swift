import Fluent
import FluentPostgresDriver
import NIOSSL
import Vapor

let SECRET_KEY = Environment.get("SECRET_KEY")!
let REFRESH_KEY = Environment.get("REFRESH_KEY")!

public func configure(_ app: Application) async throws {
    // uncomment to serve files from /Public folder
    // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))

    // For some reason decode and encode strategy are different for the Date
    // type
    // with this configuration both have the same strategy
    let encoder = JSONEncoder()
    encoder.dateEncodingStrategy = .millisecondsSince1970
    ContentConfiguration.global.use(encoder: encoder, for: .json)

    // settign the JWT keys
    app.jwt.signers.use(.hs256(key: SECRET_KEY), kid: "secret", isDefault: true)
    app.jwt.signers.use(.hs256(key: REFRESH_KEY), kid: "refresh")

    let DATABASE_URL = Environment.get("DATABASE_URL")!

    try app.databases.use(
        DatabaseConfigurationFactory.postgres(url: DATABASE_URL),
        as: .psql
    )

    // This can be used to see the generated SQL sentences
    // app.logger.logLevel = .debug

    app.migrations.add(AuthMigration01())

    if app.environment == .production {
        try await app.autoMigrate()
    }

    // register routes
    try routes(app)
}
