//
//  EventDetail.swift
//  housetainer-ios
//
//  Created by 이주상 on 2/7/24.
//

import Foundation

struct EventDetail: Hashable {
    let response: EventDetailResponse
    
    var id: String {
        response.id
    }
    var createdAt: String {
        response.createdAt.parsedDate()
    }
    var title: String {
        response.title
    }
    var scheduleType: String {
        response.scheduleType
    }
    var memberId: String {
        response.memberId
    }
    var nickname: String {
        response.member.nickname
    }
    var isHousetainer: Bool {
        response.member.memberType == "H"
    }
    var profileUrl: URL? {
        if let profileUrl = response.member.profileUrl {
            return URL(string: profileUrl)
        } else {
            return nil
        }
    }
    var detail: String {
        response.detail
    }
    var relatedLink: String {
        response.relatedLink
    }
    var imageUrl: URL {
        return URL(string: "\(Url.imageBase(Table.events.rawValue))/\(response.fileName)")!
    }
    var isPast: Bool {
        Date().isPast(response.date)
    }
    func isLiked() async -> Bool {
        await NetworkService.shared.fetchEventBookmark(memberId: response.memberId, eventId: response.id) != nil
    }
}
