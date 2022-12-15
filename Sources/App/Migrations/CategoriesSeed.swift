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
            Event(title: "Cinemaholics", description: "Ciao, bambini! We begin our Harry Potter watching marathon with the Philosopher's Stone! See you!", date: dateString, place: "Some place", categoryId: funCategoryId, organizerId: user1Id),
            Event(title: "Russian cuisine", description: "Guys, I really would like to explain to you how to cook Borsch. Borsch is amazing, prepare your stomachs!", date: dateString, place: "Kitchen", categoryId: socialCategoryId, organizerId: user3Id),
            Event(title: "Sketches", description: "I will show you how to do quick sketches and I hope it will be useful for our next challenge. See you soon!", date: dateString, place: "Collab 1-3", categoryId: designCategoryId, organizerId: user1Id),
            Event(title: "PixelArt Club", description: "After a successful past practice, I would like to have another session. So come to me guys and we will have fun!", date: dateString, place: "Lab 2", categoryId: designCategoryId, organizerId: user3Id),
            Event(title: "Italian language", description: "Buongiorno! Come va? Today we will learn a few basic Italian words and I hope foreigners enjoy it!", date: dateString, place: "Collab 2-2", categoryId: socialCategoryId, organizerId: user1Id),
            Event(title: "Trip to Rome", description: "Let’s see some of the ancient sights of our beautiful capital. Our Italian volunteers will show you the most impressive views.", date: dateString, place: "Piazza Garibaldi", categoryId: funCategoryId, organizerId: user3Id)
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
