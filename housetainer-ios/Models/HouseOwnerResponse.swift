//
//  HouseOwnerResponse.swift
//  housetainer-ios
//
//  Created by 이주상 on 2/23/24.
//

import Foundation

struct HouseOwnerResponse: Decodable {
    let id: String
    let memberType: String
    let nickname: String
    let profileUrl: String?
    
    enum CodingKeys: String, CodingKey {
        case id, nickname
        case memberType = "member_type"
        case profileUrl = "profile_photo"
    }
}
