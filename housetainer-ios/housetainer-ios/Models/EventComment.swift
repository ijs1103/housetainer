//
//  EventComment.swift
//  housetainer-ios
//
//  Created by 이주상 on 2/12/24.
//

import Foundation

struct EventComment: Codable {
    let id: String
    let eventId: String
    let content: String
    let createdAt: Date
    let updatedAt: Date
    let parentCommentId: String?
    let writerId: String
    
    enum CodingKeys: String, CodingKey {
        case id, content
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case eventId = "event_id"
        case writerId = "writer_id"
        case parentCommentId = "parent_comment_id"
    }
}
