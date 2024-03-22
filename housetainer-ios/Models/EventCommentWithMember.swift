//
//  CommentWithMember.swift
//  housetainer-ios
//
//  Created by 이주상 on 2/8/24.
//

import Foundation

struct EventCommentWithMember: Hashable {
    let response: EventCommentWithMemberRes
    var id: String {
        response.id
    }
    var eventId: String {
        response.eventId
    }
    var content: String {
        response.content
    }
    var writerId: String {
        response.writerId
    }
    var parentCommentId: String? {
        response.parentCommentId
    }
    var createdAt: String {
        response.createdAt.parsedDate()
    }
    var updatedAt: String {
        response.updatedAt.parsedDate()
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
}
