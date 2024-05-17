//
//  HouseResponse.swift
//  Housetainer
//
//  Created by 이주상 on 2023/11/21.
//

import Foundation

struct HouseResponse: Codable, Hashable {
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
    
    enum CodingKeys: String, CodingKey {
        case id, name, category, title, content, domestic, location
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case ownerId = "owner_id"
        case detailedLocation = "detailed_location"
        case displayType = "display_type"
        case imageURLs = "image_urls"
        case coverImageIndex = "cover_image_index"
    }
}

enum HouseCategory: String {
    case artist = "예술가의 집"
    case creator = "크리에이터의 집"
    case designer = "공간 디자이너의 집"
    case collector = "컬렉터의 집"
}
