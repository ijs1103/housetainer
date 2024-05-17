//
//  BuddyDTO.swift
//  housetainer-ios
//
//  Created by 이주상 on 4/17/24.
//

import Foundation

struct BuddyDTO: Codable {
    let ownerId: String?
    let buddyId: String
    let createdAt: Date
    
    enum CodingKeys: String, CodingKey {
        case ownerId = "owner_id"
        case buddyId = "buddy_id"
        case createdAt = "created_at"
    }
}
