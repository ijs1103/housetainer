//
//  MemberWithInviterRes.swift
//  housetainer-ios
//
//  Created by 이주상 on 4/20/24.
//

import Foundation

struct MemberWithInviterRes: Decodable {
    
    let id: String?
    let memberStatus: String?
    let createdAt: Date?
    let memberType: String?
    let name: String?
    let loginId: String?
    let username: String?
    let gender: String?
    let birthday: String?
    let phoneNumber: String?
    let snsUrl: String?
    let profileUrl: String?
    let updatedAt: Date?
    let inviterId: String?
    let inviter: Inviter?

    enum CodingKeys: String, CodingKey {
        case id, name, username, gender, birthday, inviter
        case memberStatus = "member_status"
        case createdAt = "created_at"
        case memberType = "member_type"
        case loginId = "login_id"
        case phoneNumber = "phone_no"
        case snsUrl = "sns_url"
        case profileUrl = "profile_photo"
        case updatedAt = "updated_at"
        case inviterId = "inviter_id"
    }
}

struct Inviter: Decodable {
    let username: String
}
