//
//  SocialCalendarDetailVM.swift
//  housetainer-ios
//
//  Created by 이주상 on 2023/12/02.
//
import Foundation
import Combine

final class SocialCalendarDetailVM {
    private let eventId: String
    let isCommentRegistered = CurrentValueSubject<Bool?, Never>(nil)
    let isCommentEmpty = CurrentValueSubject<Bool?, Never>(nil)
    let isEventDeleted = CurrentValueSubject<Bool?, Never>(nil)
    let event = CurrentValueSubject<EventDetail?, Never>(nil)
    let comments = CurrentValueSubject<[CommentCellData]?, Never>(nil)
    let house = CurrentValueSubject<House?, Never>(nil)
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
        let parsed = response.map { EventCommentWithMember(response: $0) }
        let data = parsed.map { CommentCellData(nickname: $0.nickname, createdAt: $0.createdAt, content: $0.content, profileUrl: $0.profileUrl, isHousetainer: $0.isHousetainer) }
        comments.send(data)
    }
    
    func fetchHouseByOwnerId() async {
        guard let ownerId = event.value?.memberId, let response = await NetworkService.shared.fetchHouseByOwnerId(ownerId) else { return }
        house.send(House(response: response))
    }
    
    func registerComment(text: String) async {
        guard let writerId = await NetworkService.shared.userInfo()?.id.uuidString else { return isCommentRegistered.send(false) }
        let comment = EventComment(id: UUID().uuidString, eventId: eventId, content: text, createdAt: Date(), updatedAt: Date(), parentCommentId: nil, writerId: writerId)
        do {
            try await NetworkService.shared.insertEventComments(comment)
            isCommentRegistered.send(true)
        } catch {
            print("insertEventComments - supabase error")
            isCommentRegistered.send(false)
        }
    }
    
    func isMyEvent(memberId: String) async -> Bool {
        let info = await NetworkService.shared.userInfo()
        if let currentMemberId = info?.identities?.first?.userId.uuidString.lowercased(), memberId == currentMemberId {
            return true
        }
        return false
    }
    
    func deleteEvent() async {
        let isEventDeletedValue = await NetworkService.shared.deleteEvent(id: eventId)
        isEventDeleted.send(isEventDeletedValue)
    }
}
