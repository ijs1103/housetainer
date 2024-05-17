//
//  NotificationDTO.swift
//  housetainer-ios
//
//  Created by 이주상 on 4/10/24.
//

import Foundation

struct NotificationDTO: Codable {
    let id: String
    let createdAt: Date
    let read: Bool
    let type: String
    let ownerId: String
    let actorId: String
    let actorUsername: String
    let houseId: String?
    let houseCommentId: String?
    let eventId: String?
    let eventCommentId: String?
    
    enum CodingKeys: String, CodingKey {
        case id, read, type
        case createdAt = "created_at"
        case ownerId = "owner_id"
        case actorId = "actor_id"
        case actorUsername = "actor_username"
        case houseId = "house_id"
        case houseCommentId = "house_comment_id"
        case eventId = "event_id"
        case eventCommentId = "event_comment_id"
    }
}
