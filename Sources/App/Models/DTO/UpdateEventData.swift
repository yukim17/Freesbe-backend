//
//  UpdateEventData.swift
//  
//
//  Created by Ekaterina Grishina on 10/12/22.
//

import Vapor

struct UpdateEventData: Content {
    let id: UUID
    let title: String?
    let description: String?
    let place: String?
//    let date: Date
    let categoryId: UUID?
}
