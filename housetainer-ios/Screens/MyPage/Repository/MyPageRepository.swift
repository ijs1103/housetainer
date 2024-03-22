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
    
    func requestMyPageHouses(by userId: String?, cursor: String) async throws -> [MyPageHouse]
    
    func requestCalendars(by userId: String?, cursor: String) async throws -> [MyPageCalendar]
    
    func requestMyPageEvents(by userId: String?, cursor: String) async throws -> [MyPageEvent]
    
    func requestMyPageBookmarkedEvents(by userId: String?, cursor: String) async throws -> [MyPageEvent]
    
    @discardableResult
    func requestBookmarkEvent(by userId: String?, id: String, isBookmarked: Bool) async throws -> Bool
}

private extension MyPageRepository{
    func canInvite(user: MyPageUser, invitations: [MyPageInvitation]) -> Bool{
        user.isOwner && invitations.count < 3
    }
}

struct MyPageRepositoryImpl: MyPageRepository{
    
    func requestMyPage(by userId: String?) async throws -> MyPage {
        let (user, invitations) = try await requestUserAndInvitations(by: userId)
        let houses = try await requestHouses(by: userId, perPage: 3)
        let _ = try await requestCalendars(by: userId, perPage: 3)
        let events = try await requestEvents(by: userId, perPage: 3)
        let bookmarkedEvents = try await requestBookmarkedEvents(by: userId, perPage: 3)
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
    
    func requestCalendars(by userId: String?, cursor: String) async throws -> [MyPageCalendar] {
        try await requestCalendars(by: userId, perPage: 3, cursor: cursor)
    }
    
    func requestMyPageHouses(by userId: String?, cursor: String) async throws -> [MyPageHouse]{
        try await requestHouses(by: userId, perPage: 3, cursor: cursor)
    }
    
    func requestMyPageEvents(by userId: String?, cursor: String) async throws -> [MyPageEvent] {
        try await requestEvents(by: userId, perPage: 10, cursor: cursor)
    }
    
    func requestMyPageBookmarkedEvents(by userId: String?, cursor: String) async throws -> [MyPageEvent] {
        try await requestBookmarkedEvents(by: userId, perPage: 10, cursor: cursor)
    }
    
    func requestBookmarkEvent(by userId: String?, id: String, isBookmarked: Bool) async throws -> Bool {
        do{
            if isBookmarked{
                let data = try await ApolloClient.shared.perform(mutation: DeleteEventBookmarkMutation(id: id))
                return data?.deleteFromevent_bookmarksCollection.affectedCount != 0
            }else{
                let session = try await SupabaseClient.shared.auth.session
                let data = try await ApolloClient.shared.perform(mutation: CreateEventBookmarkMutation(
                    id: id,
                    ownerId: userId.ifNil(then: session.user.id.uuidString),
                    createdAt: Date().datetime())
                )
                return data?.insertIntoevent_bookmarksCollection?.affectedCount != 0
            }
        }catch{
            throw MyPageError.underlying(error)
        }
    }
    
    private func requestUserAndInvitations(by userId: String?) async throws -> (user: MyPageUser, invitations: [MyPageInvitation]){
        do{
            let session = try await SupabaseClient.shared.auth.session
            let data = try await ApolloClient.shared.fetch(query: MyPageHeaderQuery(userId: userId.ifNil(then: session.user.id.uuidString)))
            guard let data = data else{ throw MyPageError.notFound }
            guard let user = data.user?.edges.first?.node else{ throw MyPageError.notFound }
            
            let myPageUser = MyPageUser(
                id: user.id,
                profileURL: URL(string: user.profileUrl.ifNil(then: "")),
                nickname: user.nickname.ifNil(then: ""),
                memberType: MemberType(rawValue: user.memberType.ifNil(then: "")).ifNil(then: .normal),
                isOwner: user.id.caseInsensitiveCompare(session.user.id.uuidString) == .orderedSame
            )
            let invitations = (data.invitations?.edges).ifNil(then: []).map{
                // TODO: 백엔드 미구현
                MyPageInvitation(
                    id: "",
                    userProfileURL: nil,
                    name: $0.node.name,
                    status: InvitationStatus(rawValue: $0.node.status).ifNil(then: .invited)
                )
            }
            return (user: myPageUser, invitations: invitations)
        }catch{
            throw MyPageError.underlying(error)
        }
    }
    
    private func requestHouses(by userId: String?, perPage: Int, cursor: String? = nil) async throws -> [MyPageHouse]{
        do{
            let session = try await SupabaseClient.shared.auth.session
            let data = try await ApolloClient.shared.fetch(query: MyPageHousesQuery(
                ownerId: userId.ifNil(then: session.user.id.uuidString),
                perPage: perPage,
                cursor: .init(wrap: cursor)
            ))
            guard let data = data else{ throw MyPageError.notFound }
            guard let houses = data.houses?.edges else{ throw MyPageError.notFound }
            
            return houses.map{
                MyPageHouse(
                    id: $0.node.id,
                    title: $0.node.title,
                    imageURLs: $0.node.imageUrls.compactMap{ URL(string: $0.ifNil(then: "")) }
                )
            }
        }catch{
            throw MyPageError.underlying(error)
        }
    }
    
    private func requestCalendars(by userId: String?, perPage: Int, cursor: String? = nil) async throws -> [MyPageCalendar]{
        []
    }
    
    private func requestEvents(by userId: String?, perPage: Int, cursor: String? = nil) async throws -> [MyPageEvent]{
        do{
            let session = try await SupabaseClient.shared.auth.session
            let data = try await ApolloClient.shared.fetch(query: MyPageMyEventsQuery(
                ownerId: userId.ifNil(then: session.user.id.uuidString),
                current: Date().ISO8601Format(),
                perPage: perPage,
                cursor: .init(wrap: cursor)
            ))
            guard let data = data else{ throw MyPageError.notFound }
            guard let events = data.events?.edges else{ throw MyPageError.notFound }
            
            return events.map{
                MyPageEvent(
                    id: $0.node.id,
                    scheduleType: $0.node.scheduleType,
                    memberType: MemberType(rawValue: $0.node.members.memberType.ifNil(then: "")).ifNil(then: .normal),
                    imageURL: URL(string: "\(Url.imageBase(Table.events.rawValue))/\($0.node.imageName.ifNil(then: ""))")!,
                    title: $0.node.title, nickname: $0.node.members.nickname.ifNil(then: ""),
                    updatedAt: Date(datetime: $0.node.date).ifNil(then: Date()),
                    isBookmarked: false
                )
            }
        }catch{
            throw MyPageError.underlying(error)
        }
    }
    
    private func requestBookmarkedEvents(by userId: String?, perPage: Int, cursor: String? = nil) async throws -> [MyPageEvent]{
        do{
            let session = try await SupabaseClient.shared.auth.session
            let data = try await ApolloClient.shared.fetch(query: MyPageBookmarkedEventsQuery(
                ownerId: userId.ifNil(then: session.user.id.uuidString),
                perPage: perPage,
                cursor: .init(wrap: cursor)
            ))
            guard let data = data else{ throw MyPageError.notFound }
            guard let events = data.events?.edges else{ throw MyPageError.notFound }
            
            return events.map{
                MyPageEvent(
                    id: $0.node.event.id,
                    scheduleType: $0.node.event.scheduleType,
                    memberType: MemberType(rawValue: $0.node.event.members.memberType.ifNil(then: "")).ifNil(then: .normal),
                    imageURL: URL(string: "\(Url.imageBase(Table.events.rawValue))/\($0.node.event.imageName.ifNil(then: ""))")!,
                    title: $0.node.event.title,
                    nickname: $0.node.event.members.nickname.ifNil(then: ""),
                    updatedAt: Date(datetime: $0.node.event.date).ifNil(then: Date()),
                    isBookmarked: true
                )
            }
        }catch{
            throw MyPageError.underlying(error)
        }
    }
}

struct MyPageRepositoryMock: MyPageRepository{
    func requestMyPageHouses(by userId: String?, cursor: String) async throws -> [MyPageHouse] {
        try await Task.sleep(nanoseconds: 300 * 1000)
        return (0..<3).map{
            MyPageHouse(
                id: "house\($0)",
                title: "The Test House\($0)",
                imageURLs: [
                    URL(string: "https://picsum.photos/200?id=0")!,
                    URL(string: "https://picsum.photos/200?id=1")!,
                    URL(string: "https://picsum.photos/200?id=2")!,
                ]
            )
        }
    }
    
    func requestCalendars(by userId: String?, cursor: String) async throws -> [MyPageCalendar] {
        try await Task.sleep(nanoseconds: 300 * 1000)
        return []
    }
    
    func requestMyPageEvents(by userId: String?, cursor: String) async throws -> [MyPageEvent] {
        try await Task.sleep(nanoseconds: 300 * 1000)
        return (0..<3).map{
            MyPageEvent(
                id: "event\($0)", 
                scheduleType: "scheduleType",
                memberType: .housetainer,
                imageURL: URL(string: "https://picsum.photos/200?id=0"),
                title: "title\($0)",
                nickname: "event\($0)",
                updatedAt: Date(),
                isBookmarked: false
            )
        }
    }
    
    func requestMyPageBookmarkedEvents(by userId: String?, cursor: String) async throws -> [MyPageEvent] {
        try await Task.sleep(nanoseconds: 300 * 1000)
        return (0..<3).map{
            MyPageEvent(
                id: "bookmarked event\($0)",
                scheduleType: "scheduleType",
                memberType: .housetainer,
                imageURL: URL(string: "https://picsum.photos/200?id=0"),
                title: "bookmarked title\($0)",
                nickname: "bookmarked event\($0)",
                updatedAt: Date(),
                isBookmarked: true
            )
        }
    }
    
    func requestMyPage(by userId: String?) async throws -> MyPage {
        do{
            try await Task.sleep(nanoseconds: 300 * 1000)
            let myPageUser = MyPageUser(
                id: "test",
                profileURL: URL(string: "https://picsum.photos/200"),
                nickname: "test nickname",
                memberType: .housetainer,
                isOwner: true
            )
            let invitations = [
//                MyPageInvitation(
//                    userProfileURL: URL(string: "https://picsum.photos/200"),
//                    name: "invited user1",
//                    status: .invited
//                ),
                MyPageInvitation(
                    id: "",
                    userProfileURL: nil,
                    name: "sent user1",
                    status: .sent
                ),
                MyPageInvitation(
                    id: "",
                    userProfileURL: nil,
                    name: "expired user2",
                    status: .expired
                )
            ]
            let calendars = try await requestCalendars(by: userId, cursor: "")
            let events = try await requestMyPageEvents(by: userId, cursor: "")
            let bookmarkedEvents = try await requestMyPageBookmarkedEvents(by: userId, cursor: "")
            return MyPage(
                user: myPageUser,
                invitations: invitations,
                canInvite: canInvite(user: myPageUser, invitations: invitations),
                houses: (0..<3).map{
                    MyPageHouse(
                        id: "house\($0)",
                        title: "The Test House\($0)",
                        imageURLs: [
                            URL(string: "https://picsum.photos/200?id=0")!,
                            URL(string: "https://picsum.photos/200?id=1")!,
                            URL(string: "https://picsum.photos/200?id=2")!,
                        ]
                    )
                },
                calendars: calendars,
                events: events,
                bookmarkedEvents: bookmarkedEvents
            )
        }catch{
            throw MyPageError.underlying(error)
        }
    }
    
    func requestBookmarkEvent(by userId: String?, id: String, isBookmarked: Bool) async throws -> Bool {
        true
    }
}
