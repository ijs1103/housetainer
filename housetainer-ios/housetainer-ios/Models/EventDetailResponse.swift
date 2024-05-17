//
//  EventDetailResponse.swift
//  housetainer-ios
//
//  Created by 이주상 on 2/7/24.
//

import Foundation

struct EventDetailResponse: Decodable, Hashable {
    
    let id: String
    let title: String
    let member: EventDetailResponseMember
    let detail: String
    let createdAt: Date
    let imageUrls: [String]
    let ownerId: String
    let relatedLink: String
    let scheduleType: String
    let date: Date
    
    enum CodingKeys: String, CodingKey {
        case id, title, member, detail, date
        case createdAt = "created_at"
        case imageUrls = "image_urls"
        case ownerId = "owner_id"
        case relatedLink = "related_link"
        case scheduleType = "schedule_type"
    }
}

struct EventDetailResponseMember: Decodable, Hashable {
    let username: String
    let memberType: String
    let profileUrl: String?
    
    enum CodingKeys: String, CodingKey {
        case username
        case memberType = "member_type"
        case profileUrl = "profile_photo"
    }
}
