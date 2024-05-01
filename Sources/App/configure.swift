import NIOSSL
import Fluent
import FluentPostgresDriver
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

    app.databases.use(DatabaseConfigurationFactory.postgres(configuration: .init(
        hostname: Environment.get("DATABASE_HOST") ?? "localhost",
        port: Environment.get("DATABASE_PORT").flatMap(Int.init(_:)) ?? SQLPostgresConfiguration.ianaPortNumber,
        username: Environment.get("DATABASE_USERNAME") ?? "vapor_username",
        password: Environment.get("DATABASE_PASSWORD") ?? "vapor_password",
        database: Environment.get("DATABASE_NAME") ?? "vapor_database",
        tls: .prefer(try .init(configuration: .clientDefault)))
    ), as: .psql)
    
    // This can be used to see the generated SQL sentences
    // app.logger.logLevel = .debug

    app.migrations.add(AuthMigration01())
    
    if app.environment == .production {
        try await app.autoMigrate()
    }
    
    // register routes
    try routes(app)
}
