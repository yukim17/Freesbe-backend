//
//  File.swift
//  
//
//  Created by Ekaterina Grishina on 10/12/22.
//

import Fluent
import Foundation

struct CategoriesSeed: AsyncMigration {
    
    func prepare(on database: Database) async throws {
        let categories = [
            Category(name: "Design", description: "", color: ""),
            Category(name: "Code", description: "", color: ""),
            Category(name: "Games", description: "", color: ""),
            Category(name: "Social", description: "", color: ""),
            Category(name: "Business", description: "", color: ""),
            Category(name: "Others", description: "", color: "")
        ]
        
        let _ = categories.map { category in
            category.save(on: database)
        }.flatten(on: database.eventLoop)
    }
    
    func revert(on database: Database) async throws {
        try await Category.query(on: database).delete()
    }
}

struct EventsSeed: AsyncMigration {
    
    func prepare(on database: Database) async throws {
        let user1 = User(name: "John", surname: "Doe", username: "jdoe")
        let user2 = User(name: "Angela", surname: "Doe", username: "adoe")
        let user3 = User(name: "Will", surname: "Smith", username: "wsmith")
        try await [user1, user2, user3].create(on: database)
        
        let category = try await database.query(Category.self).first()
        guard let userId = user1.id, let categoryId = category?.id else {
            throw FluentError.idRequired
        }
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d.MM.YYYY, hh:mm"
        let dateString = dateFormatter.string(from: date)
        let events = [
            Event(title: "Some event 1", date: dateString, place: "Some place", categoryId: categoryId, organizerId: userId),
            Event(title: "Some event 2", date: dateString, place: "Some place", categoryId: categoryId, organizerId: userId),
            Event(title: "Some event 3", date: dateString, place: "Some place", categoryId: categoryId, organizerId: userId),
            Event(title: "Some event 4", date: dateString, place: "Some place",categoryId: categoryId, organizerId: userId),
            Event(title: "Some event 5", date: dateString, place: "Some place", categoryId: categoryId, organizerId: userId)
        ]
        
        let _ = events.map { event in
            event.save(on: database)
        }.flatten(on: database.eventLoop)
    }
    
    func revert(on database: Database) async throws {
        try await User.query(on: database).delete()
        try await Event.query(on: database).delete()
    }
}
