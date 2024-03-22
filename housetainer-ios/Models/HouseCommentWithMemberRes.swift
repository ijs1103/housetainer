//
//  HouseCommentWithMemberRes.swift
//  housetainer-ios
//
//  Created by 이주상 on 2/26/24.
//

import Foundation

struct HouseCommentWithMemberRes: Codable, Hashable {
    let id: String
    let content: String
    let createdAt: Date
    let updatedAt: Date
    let houseId: String
    let writerId: String
    let parentCommentId: String?
    let member: CommentMember
    
    enum CodingKeys: String, CodingKey {
        case id, content, member
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case houseId = "house_id"
        case writerId = "writer_id"
        case parentCommentId = "parent_comment_id"
    }
}
