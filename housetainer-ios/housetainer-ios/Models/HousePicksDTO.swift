//
//  HousePicksDTO.swift
//  housetainer-ios
//
//  Created by 이주상 on 4/25/24.
//

import Foundation

struct HousePicksDTO: Codable {
    let houseId: String
    let createdAt: Date

    enum CodingKeys: String, CodingKey {
        case houseId = "house_id"
        case createdAt = "created_at"
    }
}
