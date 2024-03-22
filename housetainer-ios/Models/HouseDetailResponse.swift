//
//  HouseDetailResponse.swift
//  housetainer-ios
//
//  Created by 이주상 on 2/28/24.
//

import Foundation

struct HouseDetailResponse: Decodable {
    
    let id: String?
    let createdAt: Date?
    let updatedAt: Date?
    let ownerId: String?
    let name: String?
    let category: String
    let title: String?
    let content: String?
    let imageURLs: [String]?
    let coverImageIndex: Int
    let domestic: Bool?
    let location: String?
    let detailedLocation: String?
    let displayType: String?
    let owner: HouseDetailResponseOwner
    
    enum CodingKeys: String, CodingKey {
        case id, name, category, title, content, imageURLs, coverImageIndex, domestic, location, owner
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case ownerId = "owner_id"
        case detailedLocation = "detailed_location"
        case displayType = "display_type"
    }
}

struct HouseDetailResponseOwner: Decodable {
    let nickname: String
    let memberType: String
    let profileUrl: String?
    
    enum CodingKeys: String, CodingKey {
        case nickname
        case memberType = "member_type"
        case profileUrl = "profile_photo"
    }
}
