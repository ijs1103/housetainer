//
//  HouseCommentWithMember.swift
//  housetainer-ios
//
//  Created by 이주상 on 2/26/24.
//

import Foundation

struct HouseCommentWithMember: Hashable {
    let response: HouseCommentWithMemberRes
    var id: String {
        response.id
    }
    var houseId: String {
        response.houseId
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
