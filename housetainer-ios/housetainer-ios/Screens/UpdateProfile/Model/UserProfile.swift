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
    var username: String
    var gender: Gender?
    var birthday: Date?
    var profileRef: ImageReference?
    var canUpdateNickname: Bool = true
    var canUpdate: Bool = false
    var isCompleted: Bool = false
    var isLoading: Bool = false
}
