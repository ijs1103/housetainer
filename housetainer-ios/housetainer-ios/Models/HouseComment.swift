//
//  HouseComment.swift
//  housetainer-ios
//
//  Created by 이주상 on 2/28/24.
//

import Foundation

struct HouseComment: Codable {
    let id: String
    let houseId: String
    let content: String
    let createdAt: Date
    let updatedAt: Date
    let parentCommentId: String?
    let writerId: String
    
    enum CodingKeys: String, CodingKey {
        case id, content
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case houseId = "house_id"
        case writerId = "writer_id"
        case parentCommentId = "parent_comment_id"
    }
}
