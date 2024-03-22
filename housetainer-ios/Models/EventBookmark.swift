//
//  EventBookmark.swift
//  housetainer-ios
//
//  Created by 이주상 on 2/15/24.
//

import Foundation

struct EventBookmark: Codable {
    let memberId: String
    let eventId: String
    let createdAt: Date
   
    enum CodingKeys: String, CodingKey {
        case memberId = "member_id"
        case eventId = "event_id"
        case createdAt = "created_at"
    }
}
