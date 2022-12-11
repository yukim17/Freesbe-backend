//
//  EventController.swift
//  
//
//  Created by Ekaterina Grishina on 10/12/22.
//

import Fluent
import Vapor

struct EventController: RouteCollection {
    
    func boot(routes: RoutesBuilder) throws {
        let eventRoutes = routes.grouped("events")
        eventRoutes.get(use: index)
        eventRoutes.post("create", use: create)
        eventRoutes.get("get", use: get(req:))
        eventRoutes.get("delete", use: delete(req:))
        eventRoutes.post("update", use: update(req:))
        eventRoutes.post("join", use: join)
        eventRoutes.post("leave", use: leave(req:))
    }
    
    func index(req: Request) async throws -> [Event] {
        let events = try await Event.query(on: req.db).all()
        
        return events
    }
    
    func create(req: Request) async throws -> HTTPStatus {
        let eventData = try req.content.decode(CreateEventData.self)
        let event = Event(from: eventData)
        try await event.save(on: req.db)
        return .created
    }
    
    func get(req: Request) async throws -> Event {
        let eventId = try req.query.decode(EventIdData.self)
        guard let event = try await Event.find(eventId.id, on: req.db) else {
            throw Abort(.notFound)
        }
//        try await Event.query(on: req.db).with(\.$creator).filter(<#T##filter: ModelFieldFilter<Event, Event>##ModelFieldFilter<Event, Event>#>)
        let _ = try await event.$creator.get(on: req.db)
        
        return event
    }
    
    func update(req: Request) async throws -> Event {
        let eventData = try req.content.decode(UpdateEventData.self)
        guard let event = try await Event.find(eventData.id, on: req.db) else {
            throw Abort(.notFound)
        }
        
        event.title = eventData.title ?? event.title
        event.description = eventData.description ?? event.description
        event.place = eventData.place ?? event.place
        event.$category.id = eventData.categoryId ?? event.$category.id
        
        try await event.save(on: req.db)
        return event
    }
    
    func join(req: Request) async throws -> HTTPStatus {
        let participationData = try req.query.decode(EventParticipationData.self)
        guard let event = try await Event.find(participationData.eventId, on: req.db),
              let user = try await User.find(participationData.userId, on: req.db) else {
            throw Abort(.notFound)
        }
        
        do {
            try await event.$participants.attach(user, on: req.db)
            return .created
        } catch {
            return .notModified
        }
    }
    
    func leave(req: Request) async throws -> HTTPStatus {
        let participationData = try req.query.decode(EventParticipationData.self)
        guard let event = try await Event.find(participationData.eventId, on: req.db),
              let user = try await User.find(participationData.userId, on: req.db) else {
            throw Abort(.notFound)
        }
        
        do {
            try await event.$participants.detach(user, on: req.db)
            return .ok
        } catch {
            return .notModified
        }
    }
    
    func delete(req: Request) async throws -> HTTPStatus {
        guard let event = try await Event.find(req.parameters.get(Event.FieldKeys.id), on: req.db) else {
            throw Abort(.notFound)
        }
        try await event.delete(on: req.db)
        return .ok
    }
}


