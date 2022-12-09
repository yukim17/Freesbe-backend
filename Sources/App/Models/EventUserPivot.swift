//
//  EventUserPivot.swift
//  
//
//  Created by Ekaterina Grishina on 09/12/22.
//

import Fluent
import Vapor

final class EventUserPivot: Model, Content {
    static let schema: String = "event-user-pivot"
    
    enum FieldKeys {
        static let event: FieldKey = "eventId"
        static let user: FieldKey = "userId"
    }
    
    @ID(key: .id)
    var id: UUID?
    
    @Parent(key: FieldKeys.event)
    var event: Event
    
    @Parent(key: FieldKeys.user)
    var user: User
    
    init() {}
    
    init(
        id: UUID? = nil,
        event: Event,
        user: User
    ) throws {
        self.id = id
        self.$event.id = try event.requireID()
        self.$user.id = try user.requireID()
    }
}
