//
//  EventMomentsDTO.swift
//  housetainer-ios
//
//  Created by 이주상 on 4/25/24.
//

import Foundation

struct EventMomentsDTO: Codable {
    let eventId: String
    let createdAt: Date

    enum CodingKeys: String, CodingKey {
        case eventId = "event_id"
        case createdAt = "created_at"
    }
}
