//
//  EventParticipationData.swift
//  
//
//  Created by Ekaterina Grishina on 11/12/22.
//

import Vapor

struct EventParticipationData: Content {
    let userId: UUID
    let eventId: UUID
}
