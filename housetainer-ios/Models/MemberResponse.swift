//
//  MemberResponse.swift
//  Housetainer
//
//  Created by 이주상 on 2023/11/21.
//

import Foundation

struct MemberResponse: Codable {
    let id: String?
    let memberStatus: String?
    let createdAt: Date?
    let memberType: String?
    let name: String?
    let loginId: String?
    let nickname: String?
    let gender: String?
    let birthday: String?
    let phoneNumber: String?
    let snsUrl: String?
    let profileUrl: String?
    let updatedAt: Date?
    
    enum CodingKeys: String, CodingKey {
        case id, name, nickname, gender, birthday
        case memberStatus = "member_status"
        case createdAt = "created_at"
        case memberType = "member_type"
        case loginId = "login_id"
        case phoneNumber = "phone_no"
        case snsUrl = "sns_url"
        case profileUrl = "profile_photo"
        case updatedAt = "updated_at"
    }
}
