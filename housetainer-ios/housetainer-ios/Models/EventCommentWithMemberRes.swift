//
//  CommentWithMemberRes.swift
//  housetainer-ios
//
//  Created by 이주상 on 2/8/24.
//

import Foundation

struct EventCommentWithMemberRes: Codable, Hashable {
    let id: String
    let content: String
    let createdAt: Date
    let updatedAt: Date
    let eventId: String
    let writerId: String
    let parentCommentId: String?
    let member: CommentMember
    
    enum CodingKeys: String, CodingKey {
        case id, content, member
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case eventId = "event_id"
        case writerId = "writer_id"
        case parentCommentId = "parent_comment_id"
    }
}

struct CommentMember: Codable, Hashable {
    let username: String
    let memberType: String
    let profileUrl: String?
    
    enum CodingKeys: String, CodingKey {
        case username
        case memberType = "member_type"
        case profileUrl = "profile_photo"
    }
}
