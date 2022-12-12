//
//  GetEventsData.swift
//  
//
//  Created by Ekaterina Grishina on 11/12/22.
//

import Vapor

struct GetEventsData: Content {
    let userId: UUID?
    let userRole: UserRole?
}

enum UserRole: String, Content {
    case creator
    case participant
}
