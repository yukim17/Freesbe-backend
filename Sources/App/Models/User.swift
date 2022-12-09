//
//  User.swift
//  
//
//  Created by Ekaterina Grishina on 09/12/22.
//

import Vapor
import Fluent

final class User: Model, Content {
    
    static let schema: String = "users"
    
    enum FieldKeys {
        static let name: FieldKey = "name"
        static let surname: FieldKey = "surname"
        static let username: FieldKey = "username"
    }
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: FieldKeys.name)
    var name: String
    
    @Field(key: FieldKeys.surname)
    var surname: String
    
    @Field(key: FieldKeys.username)
    var username: String
    
    @Children(for: \.$organizer)
    var organizedEvents: [Event]
    
    @Siblings(
        through: EventUserPivot.self,
        from: \.$user,
        to: \.$event
    )
    var events: [Event]
    
    init() {}
    
    init(
        id: UUID? = nil,
        name: String,
        surname: String,
        username: String
    ) {
        self.id = id
        self.name = name
        self.surname = surname
        self.username = username
    }
}
