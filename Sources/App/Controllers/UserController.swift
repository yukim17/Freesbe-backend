//
//  File.swift
//  
//
//  Created by Ekaterina Grishina on 11/12/22.
//

import Vapor
import Fluent

struct UserController: RouteCollection {
    
    func boot(routes: RoutesBuilder) throws {
        routes.get("users", use: index)
    }
    
    func index(req: Request) async throws -> [User] {
        return try await User.query(on: req.db).all()
    }
}
