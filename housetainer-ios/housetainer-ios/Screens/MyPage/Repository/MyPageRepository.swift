//
//  MyPageRepository.swift
//  housetainer-ios
//
//  Created by 김수아 on 3/14/24.
//

import Foundation
import Supabase
import Apollo
import Interstyle

enum MyPageError: Error{
    case notFound
    case underlying(Error)
}

protocol MyPageRepository{
    func requestMyPage(by userId: String?) async throws -> MyPage
    
    func requestMyPageInvitations(by userId: String?) async throws -> [MyPageInvitation]
    
    func requestMyPageHouses(by userId: String?, cursor: String) async throws -> [MyPageHouse]
    
    func requestCalendars(by userId: String?, cursor: String) async throws -> [MyPageCalendar]
    
    func requestMyPageEvents(by userId: String?, cursor: String?) async throws -> [MyPageEvent]
    
    func requestMyPageBookmarkedEvents(by userId: String?, cursor: String?) async throws -> [MyPageEvent]
    
    @discardableResult
    func requestBookmarkEvent(by userId: String?, id: String, isBookmarked: Bool) async throws -> Bool
}

private extension MyPageRepository{
    func canInvite(user: MyPageUser, invitations: [MyPageInvitation]) -> Bool{
        user.isOwner && invitations.count < 3
    }
}

final class MyPageRepositoryImpl: MyPageRepository{
    
    func requestMyPage(by userId: String?) async throws -> MyPage {
        let user = await _requestUser(by: userId)
        let invitations = try await _requestInvitations(by: userId)
        let houses = await requestHouses(by: userId)
        let _ = try await requestCalendars(by: userId, perPage: 3)
        let events = try await requestMyEvents(by: userId)
        let bookmarkedEvents = await requestBookmarkedEvents(by: userId, perPage: 100)

        return MyPage(
            user: user,
            invitations: invitations,
            canInvite: canInvite(user: user, invitations: invitations),
            houses: houses,
            calendars: [],
            events: events,
            bookmarkedEvents: bookmarkedEvents
        )
    }
    
    func requestMyPageInvitations(by userId: String?) async throws -> [MyPageInvitation] {
        try await _requestInvitations(by: userId)
    }
    
    func requestCalendars(by userId: String?, cursor: String) async throws -> [MyPageCalendar] {
        try await requestCalendars(by: userId, perPage: 3, cursor: cursor)
    }
    
    func requestMyPageHouses(by userId: String?, cursor: String) async throws -> [MyPageHouse]{
        await requestHouses(by: userId)
    }
    
    func requestMyPageEvents(by userId: String?, cursor: String?) async throws -> [MyPageEvent] {
        await requestEvents(by: userId, perPage: 10, cursor: cursor)
    }
    
    func requestMyPageBookmarkedEvents(by userId: String?, cursor: String?) async throws -> [MyPageEvent] {
        await requestBookmarkedEvents(by: userId, perPage: 10, cursor: cursor)
    }
    
    func requestBookmarkEvent(by userId: String?, id: String, isBookmarked: Bool) async throws -> Bool {
//        do{
//            if isBookmarked{
//                let data = try await ApolloClient.shared.perform(mutation: DeleteEventBookmarkMutation(id: id))
//                return data?.deleteFromevent_bookmarksCollection.affectedCount != 0
//            }else{
//                let session = try await SupabaseClient.shared.auth.session
//                let data = try await ApolloClient.shared.perform(mutation: CreateEventBookmarkMutation(
//                    id: id,
//                    ownerId: userId.ifNil(then: session.user.id.uuidString),
//                    createdAt: Date().datetime())
//                )
//                return data?.insertIntoevent_bookmarksCollection?.affectedCount != 0
//            }
//        }catch{
//            throw MyPageError.underlying(error)
//        }
        return true
    }
    
    private func _requestUser(by userId: String?) async -> MyPageUser {
        guard let userId else { return  MyPageUser(id: "", profileRef: nil, nickname: "", memberType: .normal, isOwner: false, inviterNickname: nil) }
        let user = await NetworkService.shared.fetchMemberWithInviter(id: userId)
        let myPageUser = MyPageUser(
            id: userId,
            profileRef: URL(string: user?.profileUrl ?? "").map{ .url($0) },
            nickname: user?.username ?? "",
            memberType: MemberType(rawValue: user?.memberType.ifNil(then: "") ?? "").ifNil(then: .normal),
            isOwner: userId.caseInsensitiveCompare(userId) == .orderedSame, inviterNickname: user?.inviter?.username
        )
        return myPageUser
    }
    
    private func _requestInvitations(by userId: String?) async throws -> [MyPageInvitation] {
        guard let userId else { return [] }
        let invitations = await NetworkService.shared.fetchInvitations(by: userId)
        if invitations.isEmpty {
            return []
        }
        return invitations.map {
            MyPageInvitation(id: "", userProfileURL: nil, inviteeEmail: $0.inviteeEmail, status: InvitationStatus(rawValue: $0.status).ifNil(then: .invited))
        }
    }
    
    private func requestHouses(by userId: String?) async -> [MyPageHouse]{
        guard let userId = await NetworkService.shared.userInfo()?.id.uuidString else { return [] }
        guard let houses = await NetworkService.shared.fetchHouses(by: userId) else { return [] }
        return houses.map {
            MyPageHouse(id: $0.id ?? "", title: $0.title ?? "", imageURLs: $0.imageURLs?.compactMap { URL(string: $0) } ?? [])
        }
    }
    
    private func requestCalendars(by userId: String?, perPage: Int, cursor: String? = nil) async throws -> [MyPageCalendar]{
        []
    }
    
    private func requestMyEvents(by userId: String?) async throws -> [MyPageEvent] {
        guard let userId else { return [] }
        guard let res = await NetworkService.shared.fetchEvents(by: userId) else { return [] }
        
        return res.map { MyPageEvent(id: $0.id , scheduleType: $0.scheduleType, memberType: .normal, imageURL: URL(string: $0.imageUrls.first ?? ""), title: $0.title, nickname: "", updatedAt: $0.createdAt, isBookmarked: false)  }
    }
    
    private func requestEvents(by userId: String?, perPage: Int, cursor: String? = nil) async -> [MyPageEvent] {
        guard let userId = await NetworkService.shared.userInfo()?.id.uuidString else { return [] }
        guard let events = await NetworkService.shared.fetchEvents(by: userId) else { return [] }
        return events.map {
            MyPageEvent(id: $0.id, scheduleType: $0.scheduleType, memberType: .normal, imageURL: URL(string: $0.imageUrls.first ?? ""), title: $0.title, nickname: "", updatedAt: $0.date, isBookmarked: false)
        }
    }
    
    private func requestBookmarkedEvents(by userId: String?, perPage: Int, cursor: String? = nil) async -> [MyPageEvent]{
        guard let userId = await NetworkService.shared.userInfo()?.id.uuidString else { return [] }
        guard let events = await NetworkService.shared.fetchBookmarkedEvents(by: userId) else { return [] }
        return events.map {
            MyPageEvent(id: $0.id, scheduleType: $0.scheduleType, memberType: .normal, imageURL: URL(string: $0.imageUrls.first ?? ""), title: $0.title, nickname: $0.member.username, updatedAt: $0.date, isBookmarked: true)
        }
        
    }
}
