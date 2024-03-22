//
//  EventWithNicknameRes.swift
//  housetainer-ios
//
//  Created by 이주상 on 2/6/24.
//

import Foundation

struct EventWithNicknameRes: Decodable {
    
    let id: String
    let date: Date
    let member: EventWithNicknameResMember
    let title: String
    let fileName: String
    
    enum CodingKeys: String, CodingKey {
        case id, date, member, title
        case fileName = "file_name"
    }
}

struct EventWithNicknameResMember: Decodable {
    let nickname: String
}
