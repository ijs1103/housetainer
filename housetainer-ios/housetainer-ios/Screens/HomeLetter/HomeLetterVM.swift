//
//  HomeLetterVM.swift
//  housetainer-ios
//
//  Created by 이주상 on 2/24/24.
//

import Foundation
import Combine

final class HomeLetterVM {
    private let houseOwnerId: String
    private let houseId: String
    let comments = CurrentValueSubject<[CommentCellData]?, Never>(nil)
    let isCommentRegistered = CurrentValueSubject<Bool?, Never>(nil)
    let isCommentEmpty = CurrentValueSubject<Bool?, Never>(nil)
    let isCommentDeleted = CurrentValueSubject<Bool?, Never>(nil)
    let isUserBlocked = CurrentValueSubject<Bool?, Never>(nil)
    var blockedMembers: [BlockedMemberDTO] = []

    init(houseId: String, houseOwnerId: String) {
        self.houseId = houseId
        self.houseOwnerId = houseOwnerId
    }
}

extension HomeLetterVM {
    func fetchComments() async {
        guard let response = await NetworkService.shared.fetchHouseComments(houseId: houseId) else { return }
        let nonBlockedComments = response.filter { comment in
            !blockedMembers.contains { blockedMember in
                blockedMember.blockedMemberId == comment.writerId
            }
        }.map(HouseCommentWithMember.init)
        let data = nonBlockedComments.map { CommentCellData(id: $0.id, writerId: $0.writerId, nickname: $0.nickname, createdAt: $0.createdAt, content: $0.content, profileUrl: $0.profileUrl, isHousetainer: $0.isHousetainer) }
        comments.send(data)
    }
    
    func registerComment(text: String) async {
        guard let writerId = await NetworkService.shared.userInfo()?.id.uuidString else { return isCommentRegistered.send(false) }
        let comment = HouseComment(id: UUID().uuidString, houseId: houseId, content: text, createdAt: Date(), updatedAt: Date(), parentCommentId: nil, writerId: writerId)
        do {
            try await NetworkService.shared.insertHouseComments(comment: comment, houseOwnerId: houseOwnerId)
            isCommentRegistered.send(true)
        } catch {
            print("insertHouseComments - supabase error")
            isCommentRegistered.send(false)
        }
    }
    
    func deleteComment(id: String) async {
        let isHouseCommentDeleted = await NetworkService.shared.deleteHouseComment(id: id)
        isCommentDeleted.send(isHouseCommentDeleted)
    }
    
    func blockUser(id: String) async {
        guard let reporterId = await NetworkService.shared.userInfo()?.id.uuidString else { return }
        let blockedMember = BlockedMemberDTO(reporterId: reporterId, blockedMemberId: id)
        let isUserBlocked = await NetworkService.shared.insertBlockedMember(blockedMember)
        self.isUserBlocked.send(isUserBlocked)
    }
    
    func fetchBlockedMembers() async {
        guard let reporterId = await NetworkService.shared.userInfo()?.id.uuidString else { return }
        let blockedMembers: [BlockedMemberDTO] = await NetworkService.shared.fetchBlockedMembers(reporterId: reporterId)
        self.blockedMembers = blockedMembers
    }
}
