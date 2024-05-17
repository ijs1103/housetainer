//
//  SocialCalendarDetailVM.swift
//  housetainer-ios
//
//  Created by 이주상 on 2023/12/02.
//
import Foundation
import Combine

enum BlockType {
    case post, comment
}

final class SocialCalendarDetailVM {
    private let eventId: String
    let isCommentRegistered = CurrentValueSubject<Bool?, Never>(nil)
    let isCommentEmpty = CurrentValueSubject<Bool?, Never>(nil)
    let isEventDeleted = CurrentValueSubject<Bool?, Never>(nil)
    let isCommentDeleted = CurrentValueSubject<Bool?, Never>(nil)
    let isUserBlocked = CurrentValueSubject<(Bool, BlockType)?, Never>(nil)
    let event = CurrentValueSubject<EventDetail?, Never>(nil)
    let comments = CurrentValueSubject<[CommentCellData]?, Never>(nil)
    let house = CurrentValueSubject<House?, Never>(nil)
    var blockedMembers: [BlockedMemberDTO] = []
    init(eventId: String) {
        self.eventId = eventId
    }
}

extension SocialCalendarDetailVM {
    func fetchEvent() async {
        guard let response = await NetworkService.shared.fetchEventDetail(id: eventId) else { return }
        event.send(EventDetail(response: response))
    }
    
    func fetchComments() async {
        guard let response = await NetworkService.shared.fetchEventComments(eventId: eventId) else { return }
        let nonBlockedComments = response.filter { comment in
            !blockedMembers.contains { blockedMember in
                blockedMember.blockedMemberId == comment.writerId
            }
        }.map(EventCommentWithMember.init)
        let data = nonBlockedComments.map { CommentCellData(id: $0.id, writerId: $0.writerId, nickname: $0.nickname, createdAt: $0.createdAt, content: $0.content, profileUrl: $0.profileUrl, isHousetainer: $0.isHousetainer) }
        comments.send(data)
    }
    
    func fetchHouseByOwnerId() async {
        guard let ownerId = event.value?.memberId, let response = await NetworkService.shared.fetchHouseByOwnerId(ownerId) else { return }
        house.send(House(response: response))
    }
    
    func registerComment(text: String) async {
        guard let writerId = await NetworkService.shared.userInfo()?.id.uuidString, let eventOwnerId = event.value?.memberId else { return isCommentRegistered.send(false) }
        let comment = EventComment(id: UUID().uuidString, eventId: eventId, content: text, createdAt: Date(), updatedAt: Date(), parentCommentId: nil, writerId: writerId)
        do {
            try await NetworkService.shared.insertEventComments(comment: comment, eventOwnerId: eventOwnerId)
            isCommentRegistered.send(true)
        } catch {
            print("insertEventComments - supabase error")
            isCommentRegistered.send(false)
        }
    }
    
    func isMyEvent(memberId: String) async -> Bool {
        if let currentMemberId = await NetworkService.shared.userInfo()?.identities?.first?.userId.uuidString.lowercased(), memberId == currentMemberId {
            return true
        }
        return false
    }
    
    func deleteEvent() async {
        let isEventDeleted = await NetworkService.shared.deleteEvent(id: eventId)
        self.isEventDeleted.send(isEventDeleted)
    }
    
    func getEventId() -> String {
        eventId
    }
    
    func deleteComment(id: String) async {
        let isCommentDeleted = await NetworkService.shared.deleteEventComment(id: id)
        self.isCommentDeleted.send(isCommentDeleted)
    }
    
    func blockUser(id: String, blockType: BlockType) async {
        guard let reporterId = await NetworkService.shared.userInfo()?.id.uuidString else { return }
        let blockedMember = BlockedMemberDTO(reporterId: reporterId, blockedMemberId: id)
        let isUserBlocked = await NetworkService.shared.insertBlockedMember(blockedMember)
        self.isUserBlocked.send((isUserBlocked, blockType))
    }
    
    func fetchBlockedMembers() async {
        guard let reporterId = await NetworkService.shared.userInfo()?.id.uuidString else { return }
        let blockedMembers: [BlockedMemberDTO] = await NetworkService.shared.fetchBlockedMembers(reporterId: reporterId)
        self.blockedMembers = blockedMembers
    }
}
