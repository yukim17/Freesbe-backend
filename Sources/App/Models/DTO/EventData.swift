//
//  EventData.swift
//  
//
//  Created by Ekaterina Grishina on 10/12/22.
//

import Vapor

struct CreateEventData: Content {
    let title: String
    let description: String?
    let place: String
//    let date: Date
    let creatorId: UUID
    let categoryId: UUID
}
