//
//  MyPageTable.swift
//  housetainer-ios
//
//  Created by 김수아 on 2/28/24.
//

import Foundation

struct MyPage{
    let user: MyPageUser
    let invitations: [MyPageInvitation]
    let canInvite: Bool
    let houses: [MyPageHouse]
    let calendars: [MyPageCalendar]
    let events: [MyPageEvent]
    let bookmarkedEvents: [MyPageEvent]
    
    func copy(
        user: MyPageUser? = nil,
        invitations: [MyPageInvitation]? = nil,
        canInvite: Bool? = nil,
        houses: [MyPageHouse]? = nil,
        calendars: [MyPageCalendar]? = nil,
        events: [MyPageEvent]? = nil,
        bookmarkedEvents: [MyPageEvent]? = nil
    ) -> Self{
        .init(
            user: user ?? self.user,
            invitations: invitations ?? self.invitations,
            canInvite: canInvite ?? self.canInvite,
            houses: houses ?? self.houses,
            calendars: calendars ?? self.calendars,
            events: events ?? self.events,
            bookmarkedEvents: bookmarkedEvents ?? self.bookmarkedEvents
        )
    }
}

struct MyPageUser{
    let id: String
    let profileRef: ImageReference?
    let nickname: String
    let memberType: MemberType
    let isOwner: Bool
    let inviterNickname: String?
}

struct MyPageHouse{
    let id: String
    let title: String
    let imageURLs: [URL]
}

struct MyPageInvitation{
    let id: String
    let userProfileURL: URL?
    let inviteeEmail: String
    let status: InvitationStatus
}

struct MyPageCalendar{
    let id: String
    let scheduleType: String
    let memberType: MemberType
    let imageURL: URL?
    let nickname: String
    let title: String
    let updatedAt: Date
}

struct MyPageEvent{
    let id: String
    let scheduleType: String
    let memberType: MemberType
    let imageURL: URL?
    let title: String
    let nickname: String
    let updatedAt: Date
    var isBookmarked: Bool
}
