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
    
    enum CodingKeys: String, CodingKey {
        case id, member, category, imageURLs, coverImageIndex
    }
}

struct HouseWithNicknameResMember: Decodable {
    let nickname: String
}
