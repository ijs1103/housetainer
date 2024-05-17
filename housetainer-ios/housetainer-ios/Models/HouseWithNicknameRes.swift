//
//  HouseWithNicknameRes.swift
//  housetainer-ios
//
//  Created by 이주상 on 2/7/24.
//

import Foundation

struct HouseWithNicknameRes: Decodable {
    
    let id: String
    let member: HouseWithNicknameResMember
    let category: String
    let imageURLs: [String]?
    let coverImageIndex: Int
    let ownerId: String
    
    enum CodingKeys: String, CodingKey {
        case id, member, category
        case imageURLs = "image_urls"
        case coverImageIndex = "cover_image_index"
        case ownerId = "owner_id"
    }
}

struct HouseWithNicknameResMember: Decodable {
    let username: String
}
