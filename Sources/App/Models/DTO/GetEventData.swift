//
//  GetEventData.swift
//  
//
//  Created by Ekaterina Grishina on 10/12/22.
//

import Vapor

struct GetEventData: Content {
    let id: UUID
    let userId: UUID
}
