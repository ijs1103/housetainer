//
//  UserProfile.swift
//  housetainer-ios
//
//  Created by 김수아 on 3/17/24.
//

import Foundation

struct UserProfile{
    let id: String
    let memberType: MemberType
    let email: String
    var nickname: String
    var gender: Gender?
    var birthday: Date?
    var profileRef: ImageReference?
    var canUpdateNickname: Bool = true
    var canUpdate: Bool = false
}
