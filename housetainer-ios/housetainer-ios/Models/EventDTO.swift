//
//  EventDto.swift
//  housetainer-ios
//
//  Created by 이주상 on 2/19/24.
//

import Foundation

struct EventDTO: Codable, Hashable {
    let id: String
    let createdAt: Date
    let title: String
    let scheduleType: String
    let ownerId: String
    let date: Date
    let detail: String
    let relatedLink: String
    let displayType: String
    let imageUrls: [String]
    
    enum CodingKeys: String, CodingKey {
        case id, title, date, detail
        case createdAt = "created_at"
        case scheduleType = "schedule_type"
        case ownerId = "owner_id"
        case relatedLink = "related_link"
        case displayType = "display_type"
        case imageUrls = "image_urls"
    }
}
