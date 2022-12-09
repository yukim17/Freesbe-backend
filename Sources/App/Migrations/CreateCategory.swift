import Fluent

struct CreateCategories: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema(Category.schema)
            .id()
            .field(Category.FieldKeys.name, .string, .required)
            .field(Category.FieldKeys.description, .string, .required)
            .field(Category.FieldKeys.color, .string, .required)
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema(Category.schema).delete()
    }
}
