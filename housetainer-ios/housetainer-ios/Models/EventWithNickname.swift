//
//  EventWithNickname.swift
//  housetainer-ios
//
//  Created by 이주상 on 2/6/24.
//

import Foundation

struct EventWithNickname: Hashable {
    let response: EventWithNicknameRes
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: EventWithNickname, rhs: EventWithNickname) -> Bool {
        lhs.id == rhs.id
    }
    
    var id: String {
        response.id
    }
    var nickname: String {
        response.member.username
    }
    var title: String {
        response.title
    }
    var date: String {
        response.date.parsedDate()
    }
    var imageUrl: URL? {
        if let imageUrl = response.imageUrls.first {
            return URL(string: imageUrl)
        } else {
            return nil
        }
    }
}
