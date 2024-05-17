//
//  EventWithNicknameRes.swift
//  housetainer-ios
//
//  Created by 이주상 on 2/6/24.
//

import Foundation

struct EventWithNicknameRes: Decodable {
    
    let id: String
    let date: Date
    let member: EventWithNicknameResMember
    let title: String
    let imageUrls: [String]
    let scheduleType: String
    let ownerId: String
    
    enum CodingKeys: String, CodingKey {
        case id, date, member, title
        case imageUrls = "image_urls"
        case scheduleType = "schedule_type"
        case ownerId = "owner_id"
    }
}

struct EventWithNicknameResMember: Decodable {
    let username: String
}
