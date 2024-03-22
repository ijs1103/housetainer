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
    let fileName: String
    let memberId: String
    let relatedLink: String
    let scheduleType: String
    let date: Date
    
    enum CodingKeys: String, CodingKey {
        case id, title, member, detail, date
        case createdAt = "created_at"
        case fileName = "file_name"
        case memberId = "member_id"
        case relatedLink = "related_link"
        case scheduleType = "schedule_type"
    }
}

struct EventDetailResponseMember: Decodable, Hashable {
    let nickname: String
    let memberType: String
    let profileUrl: String?
    
    enum CodingKeys: String, CodingKey {
        case nickname
        case memberType = "member_type"
        case profileUrl = "profile_photo"
    }
}
