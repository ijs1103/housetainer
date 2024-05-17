//
//  BlockedMemberDTO.swift
//  housetainer-ios
//
//  Created by 이주상 on 5/13/24.
//

import Foundation

struct BlockedMemberDTO: Codable {
    let reporterId: String
    let blockedMemberId: String

    enum CodingKeys: String, CodingKey {
        case reporterId = "reporter_id"
        case blockedMemberId = "blocked_member_id"
    }
}

struct BlockedMemberWithUsername: Decodable {
    let member: BlockedMember
    let reporterId: String
    let blockedMemberId: String

    enum CodingKeys: String, CodingKey {
        case member
        case reporterId = "reporter_id"
        case blockedMemberId = "blocked_member_id"
    }
}

struct BlockedMember: Decodable {
    let username: String
}

