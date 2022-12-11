//
//  CreateEvent.swift
//  
//
//  Created by Ekaterina Grishina on 09/12/22.
//

import Fluent

struct CreateEvent: AsyncMigration {

    func prepare(on database: Database) async throws {
        try await database.schema(Event.schema)
            .id()
            .field(Event.FieldKeys.title, .string, .required)
            .field(Event.FieldKeys.description, .string)
//            .field(Event.FieldKeys.date, .datetime, .required)
            .field(Event.FieldKeys.place, .string, .required)
            .field(Event.FieldKeys.creator, .uuid, .required, .references(User.schema, "id"))
            .field(Event.FieldKeys.category, .uuid, .required, .references(Category.schema, "id"))
            .create()
    }
    
    func revert(on database: FluentKit.Database) async throws {
        try await database.schema(Event.schema).delete()
    }
}
