//
//  Event.swift
//  
//
//  Created by Ekaterina Grishina on 08/12/22.
//

import Fluent
import Vapor

final class Event: Model, Content {
    static let schema: String = "events"
    
    enum FieldKeys {
        static let id: String = "eventID"
        static let title: FieldKey = "title"
        static let description: FieldKey = "description"
        static let date: FieldKey = "date"
        static let place: FieldKey = "place"
        static let image: FieldKey = "image"
        static let category: FieldKey = "categoryId"
        static let creator: FieldKey = "creator"
    }
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: FieldKeys.title)
    var title: String
    
    @OptionalField(key: FieldKeys.description)
    var description: String?
    
    @Field(key: FieldKeys.date)
    var date: String
    
    @Field(key: FieldKeys.place)
    var place: String
    
    @Parent(key: FieldKeys.category)
    var category: Category

    @Parent(key: FieldKeys.creator)
    var creator: User

    @Siblings(
        through: EventUserPivot.self,
        from: \.$event,
        to: \.$user
    )
    var participants: [User]
    
    init() {}
    
    init(
        id: UUID? = nil,
        title: String,
        description: String? = nil,
        date: String,
        place: String,
        categoryId: Category.IDValue,
        organizerId: User.IDValue
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.date = date
        self.place = place
        self.$category.id = categoryId
        self.$creator.id = organizerId
    }
    
    init(from eventData: CreateEventData) {
        self.title = eventData.title
        self.description = eventData.description
        self.place = eventData.place
        self.$creator.id = eventData.creatorId
        self.$category.id = eventData.categoryId
    }
}
