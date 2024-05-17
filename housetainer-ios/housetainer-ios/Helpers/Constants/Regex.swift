//
//  Regex.swift
//  housetainer-ios
//
//  Created by 이주상 on 1/23/24.
//

import Foundation

enum Regex: String {
    case inviteCode = "^[0-9]{8}$"
    case nickname = "^[가-힣A-Za-z]*$"
    case email = "^([a-zA-Z0-9._-])+@[a-zA-Z0-9.-]+.[a-zA-Z]{3,20}$"
}
