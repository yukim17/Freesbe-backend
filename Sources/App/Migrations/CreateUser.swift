//
//  File.swift
//  
//
//  Created by Ekaterina Grishina on 09/12/22.
//

import Fluent

struct CreateUser: AsyncMigration {
    
    func prepare(on database: Database) async throws {
        try await database.schema(User.schema)
            .id()
            .field(User.FieldKeys.name, .string, .required)
            .field(User.FieldKeys.surname, .string, .required)
            .field(User.FieldKeys.username, .string, .required)
            .create()
    }
    
    func revert(on database: Database) async throws {
        try await database.schema(User.schema).delete()
    }
}
