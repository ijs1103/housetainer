//
//  MemberToUpdate.swift
//  housetainer-ios
//
//  Created by 이주상 on 5/7/24.
//

import Foundation

struct MemberToUpdate: Encodable {
    let id: String
    let profilePhoto: String
    let gender: String
    let birthday: Date
    
    enum CodingKeys: String, CodingKey {
        case id, gender, birthday
        case profilePhoto = "profile_photo"
    }
}
