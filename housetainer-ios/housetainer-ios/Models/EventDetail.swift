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
    var date: String {
        response.date.parsedDate()
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
        response.ownerId
    }
    var nickname: String {
        response.member.username
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
    var imageUrl: URL? {
        if let imageUrl = response.imageUrls.first  {
            return URL(string: imageUrl)
        } else {
            return nil
        }
    }
    var isPast: Bool {
        Date().isPast(response.date)
    }
    func isLiked() async -> Bool {
        guard let currentUserId = await NetworkService.shared.userInfo()?.id.uuidString.lowercased() else { return false }
        let isLiked = await NetworkService.shared.fetchEventBookmark(memberId: currentUserId, eventId: response.id) != nil
        return isLiked
    }
}
