import Fluent
import SQLKit

struct ResetAttemptMigration01: AsyncMigration {
  var name: String { "ResetAttemptMigration01" }

  func prepare(on database: FluentKit.Database) async throws {
    try await database.schema("reset_attempt")
      .id()
      .field("user_id", .uuid, .required, .references("user", "id"))
      .field("email", .string, .required)
      .field("code", .string, .required)
      .create()

    try await (database as! SQLDatabase)
      .create(index: "reset_attempt_email_code_index")
      .on("reset_attempt")
      .column("email")
      .column("code")
      .run()
  }

  func revert(on database: FluentKit.Database) async throws {
    try await database.schema("reset_attempt").delete()
  }
}
