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
        let eventsData = try req.query.decode(GetEventsData.self)
        
        guard let userId = eventsData.userId else {
            return try await Event.query(on: req.db)
                .with(\.$creator)
                .with(\.$category)
                .all()
        }
        
        switch eventsData.userRole {
        case .creator:
            return try await getEventsCreatedBy(user: userId, req)
        case .participant:
            return try await getEventsJoinedBy(user: userId, req)
        default:
            throw Abort(.notFound)
        }
    }
    
    func create(req: Request) async throws -> Event {
        let eventData = try req.content.decode(CreateEventData.self)
        let event = Event(from: eventData)
        try await event.save(on: req.db)
        return event
    }
    
    func get(req: Request) async throws -> Event {
        let eventId = try req.query.decode(GetEventData.self)
        guard let event = try await Event.query(on: req.db)
                .filter(\.$id == eventId.id)
                .with(\.$creator)
                .with(\.$category)
                .first() else {
            throw Abort(.notFound)
        }
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
    
    func join(req: Request) async throws -> OperationResult {
        let participationData = try req.query.decode(EventParticipationData.self)
        guard let event = try await Event.find(participationData.eventId, on: req.db),
              let user = try await User.find(participationData.userId, on: req.db) else {
            throw Abort(.notFound)
        }
        
        guard let userId = user.id, userId != event.$creator.id else {
            throw Abort(.forbidden)
        }
        
        do {
            try await event.$participants.attach(user, on: req.db)
            return OperationResult(isSuccess: true)
        } catch {
            return OperationResult(isSuccess: false)
        }
    }
    
    func leave(req: Request) async throws -> OperationResult {
        let participationData = try req.query.decode(EventParticipationData.self)
        guard let event = try await Event.find(participationData.eventId, on: req.db),
              let user = try await User.find(participationData.userId, on: req.db) else {
            throw Abort(.notFound)
        }
        
        do {
            try await event.$participants.detach(user, on: req.db)
            return OperationResult(isSuccess: true)
        } catch {
            return OperationResult(isSuccess: false)
        }
    }
    
    func delete(req: Request) async throws -> OperationResult {
        guard let event = try await Event.find(req.parameters.get(Event.FieldKeys.id), on: req.db) else {
            throw Abort(.notFound)
        }
        try await event.delete(on: req.db)
        return OperationResult(isSuccess: true)
    }
    
    // MARK: - Private
    
    private func getEventsCreatedBy(user userId: UUID, _ req: Request) async throws -> [Event] {
        return try await Event.query(on: req.db)
            .filter(\.$creator.$id == userId)
            .with(\.$creator)
            .with(\.$category)
            .with(\.$participants)
            .all()
    }
    
    private func getEventsJoinedBy(user userId: UUID, _ req: Request) async throws -> [Event] {
        return try await Event.query(on: req.db)
            .join(siblings: \.$participants)
            .filter(EventUserPivot.self, \.$user.$id == userId)
            .with(\.$creator)
            .with(\.$category)
            .all()
    }
}
