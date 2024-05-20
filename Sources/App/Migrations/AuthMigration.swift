import Fluent
import SQLKit

struct AuthMigration01: AsyncMigration {
  var name: String { "AuthMigration01" }

  func prepare(on database: FluentKit.Database) async throws {
    try await database.schema("user")
      .id()
      .field("email", .string)
      .field("password_hash", .string)

      // indexes
      .unique(on: "email")
      .create()

    try await database.schema("session")
      .id()
      .field("refresh_token", .string, .required)
      .field("user_id", .uuid, .required, .references("user", "id"))
      .create()

    // TODO: check alternatives to this
    try await (database as! SQLDatabase)
      .create(index: "refresh_token_index")
      .on("session")
      .column("refresh_token")
      .run()
  }

  func revert(on database: FluentKit.Database) async throws {
    try await database.schema("session").delete()
    try await database.schema("user").delete()
  }
}
