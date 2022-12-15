//
//  File.swift
//  
//
//  Created by Ekaterina Grishina on 10/12/22.
//

import Fluent
import Foundation

struct EventsSeed: AsyncMigration {
    
    func prepare(on database: Database) async throws {
        let designCategory = Category(name: "Design", description: "", color: "")
        let codeCategory = Category(name: "Code", description: "", color: "")
        let socialCategory = Category(name: "Social", description: "", color: "")
        let funCategory = Category(name: "Fun", description: "", color: "")
        let categories = [
            designCategory,
            codeCategory,
            Category(name: "Games", description: "", color: ""),
            socialCategory,
            funCategory,
            Category(name: "Business", description: "", color: ""),
            Category(name: "Others", description: "", color: "")
        ]
        
        try await categories.create(on: database)
        
        let _ = categories.map { category in
            category.save(on: database)
        }.flatten(on: database.eventLoop)
        
        let user1 = User(name: "John", surname: "Doe", username: "jdoe")
        let user2 = User(name: "Ahmed", surname: "Mgua", username: "amgua")
        let user3 = User(name: "Will", surname: "Smith", username: "wsmith")
        try await [user1, user2, user3].create(on: database)
        
        guard let user1Id = user1.id,
              let user2Id = user2.id,
              let user3Id = user3.id,
              let designCategoryId = designCategory.id,
              let codeCategoryId = codeCategory.id,
              let funCategoryId = funCategory.id,
              let socialCategoryId = socialCategory.id
        else {
            throw FluentError.idRequired
        }
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d.MM.YYYY, hh:mm"
        let dateString = dateFormatter.string(from: date)
        let events = [
            Event(title: "SwiftUI with Ahmed", description: "Hello everyone! It’s time for us to learn classes finally. Don’t worry, it’s not that difficult as you think. I will wait you!", date: dateString, place: "Collab 3-1", categoryId: codeCategoryId, organizerId: user2Id),
            Event(title: "Cinemaholics", description: "", date: dateString, place: "Some place", categoryId: funCategoryId, organizerId: user1Id),
            Event(title: "Russian cuisine", description: "", date: dateString, place: "Kitchen", categoryId: socialCategoryId, organizerId: user3Id),
            Event(title: "Sketches", description: "", date: dateString, place: "Collab 1-3", categoryId: designCategoryId, organizerId: user1Id),
            Event(title: "PixelArt Club", description: "", date: dateString, place: "Lab 2", categoryId: designCategoryId, organizerId: user3Id),
            Event(title: "Italian language", description: "", date: dateString, place: "Collab 2-2", categoryId: socialCategoryId, organizerId: user1Id),
            Event(title: "Trip to Rome", description: "", date: dateString, place: "Piazza Garibaldi", categoryId: funCategoryId, organizerId: user3Id)
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
