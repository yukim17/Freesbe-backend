//
//  CreateEventUserPivot.swift
//  
//
//  Created by Ekaterina Grishina on 09/12/22.
//

import Fluent

struct CreateEventUserPivot: AsyncMigration {
    
    func prepare(on database: Database) async throws {
        try await database.schema(EventUserPivot.schema)
            .id()
            .field(
                EventUserPivot.FieldKeys.user,
                    .uuid,
                    .required,
                    .references(User.schema, "id", onDelete: .cascade)
            )
            .field(
                EventUserPivot.FieldKeys.event,
                    .uuid,
                    .required,
                    .references(Event.schema, "id", onDelete: .cascade)
            )
            .create()
    }
    
    func revert(on database: Database) async throws {
        try await database.schema(EventUserPivot.schema).delete()
    }
}
