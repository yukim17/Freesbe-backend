//
//  CreateToken.swift
//  
//
//  Created by Ekaterina Grishina on 11/12/22.
//

import Fluent

struct CreateToken: AsyncMigration {
    
    func prepare(on database: Database) async throws {
        try await database.schema(Token.schema)
              .id()
              .field(Token.FieldKeys.value, .string, .required)
              .field(
                Token.FieldKeys.userId,
                .uuid,
                .required,
                .references(User.schema, "id", onDelete: .cascade)
              )
              .create()
    }
    
    func revert(on database: Database) async throws {
        try await database.schema(Token.schema).delete()
    }
}
