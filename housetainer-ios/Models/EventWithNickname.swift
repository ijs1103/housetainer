//
//  EventWithNickname.swift
//  housetainer-ios
//
//  Created by 이주상 on 2/6/24.
//

import Foundation

struct EventWithNickname {
    let response: EventWithNicknameRes
    
    var id: String {
        response.id
    }
    var nickname: String {
        response.member.nickname
    }
    var title: String {
        response.title
    }
    var date: String {
        response.date.parsedDate()
    }
    var imageUrl: URL {
        return URL(string: "\(Url.imageBase(Table.events.rawValue))/\(response.fileName)")!
    }
}
