//
//  NetworkService.swift
//  Housetainer
//
//  Created by 이주상 on 2023/11/21.
//

import Supabase
import Foundation

final class NetworkService {
    static let shared = NetworkService()
    private var supabase = SupabaseClient(supabaseURL: Env.supabaseURL, supabaseKey: Env.supabaseKey)
    
    func setupSupabase(_ supabase: SupabaseClient) {
        self.supabase = supabase
    }
    
    func insertEvent(_ event: EventDTO) async throws {
        try await supabase.database
            .from(Table.events.rawValue)
            .insert(event)
            .execute()
    }
    
    func fetchEventDetail(id: String) async -> EventDetailResponse? {
        do {
            let res: EventDetailResponse = try await supabase.database
                .from(Table.events.rawValue)
                .select(
                    """
                    id, title, member:owner_id(username, member_type, profile_photo), detail, created_at,
                    image_urls, owner_id, related_link, schedule_type, date
                    """
                )
                .eq("id", value: id)
                .limit(1)
                .single()
                .execute()
                .value
            return res
        } catch {
            print("fetchEventDetail - supabase error")
        }
        return nil
    }
    
    func fetchEventComments(eventId: String) async -> [EventCommentWithMemberRes]? {
        do {
            let res: [EventCommentWithMemberRes] = try await supabase.database
                .from(Table.eventComments.rawValue)
                .select(
                    """
                    id,
                    content,
                    created_at,
                    updated_at,
                    event_id,
                    writer_id,
                    parent_comment_id,
                    member:writer_id(username, member_type, profile_photo)
                    """
                )
                .eq("event_id", value: eventId)
                .order("created_at", ascending: false)
                .execute()
                .value
            return res
        } catch {
            print("fetchComments - supabase error")
        }
        return nil
    }
    
    func fetchEvents(by ownerId: String) async -> [EventDTO]? {
        do {
            let result: [EventDTO] = try await supabase.database
                .from(Table.events.rawValue)
                .select()
                .eq("owner_id", value: ownerId)
                .order("created_at", ascending: false)
                .execute()
                .value
            return result
        } catch {
            print("fetchEvents by ownerId - supabase error")
            return nil
        }
    }
    
    func fetchOngoingEvents(from: Int = 0, to: Int = 3) async -> [EventDetailResponse]? {
        do {
            let events: [EventDetailResponse] = try await supabase.database
                .from(Table.events.rawValue)
                .select(
                    """
                    id, title, member:owner_id(username, member_type, profile_photo), detail, created_at,
                    image_urls, owner_id, related_link, schedule_type, date
                    """
                )
                .gte("date", value: Date().toISO8601String())
                .order("date", ascending: true)
                .range(from: from, to: to)
                .execute()
                .value
            return events
        } catch {
            print("fetchOngoingEvents - supabase error")
            return nil
        }
    }
    
    func fetchPastEvents(from: Int = 0, to: Int = 3) async -> [EventDetailResponse]? {
        do {
            let events: [EventDetailResponse] = try await supabase.database
                .from(Table.events.rawValue)
                .select(
                    """
                    id, title, member:owner_id(username, member_type, profile_photo), detail, created_at,
                    image_urls, owner_id, related_link, schedule_type, date
                    """
                )
                .lt("date", value: Date().toISO8601String())
                .order("date", ascending: false)
                .range(from: from, to: to)
                .execute()
                .value
            return events
        } catch {
            print("fetchPastEvents - supabase error")
            return nil
        }
    }
    
    func fetchEventMoments() async -> [EventDTO]? {
        do {
            let eventMoments: [EventMomentsDTO] = try await supabase.database
                .from(Table.eventMoments.rawValue)
                .select()
                .limit(6)
                .execute()
                .value
            let ids = eventMoments.map{ $0.eventId }
            let result = await fetchEvents(ids: ids)
            return result
        } catch {
            print("fetchEventMoments - supabase error")
            return nil
        }
    }
    
    private func fetchEvents(ids: [String]) async -> [EventDTO]? {
        do {
            let result: [EventDTO] = try await supabase.database
                .from(Table.events.rawValue)
                .select()
                .in("id", value: ids)
                .order("created_at", ascending: false)
                .execute()
                .value
            return result
        } catch {
            print("fetchEvents by id - supabase error")
            return nil
        }
    }
    
    func fetchBookmarkedEvents(by ownerId: String) async -> [EventWithNicknameRes]? {
        do {
            let eventBookmarks: [EventBookmark] = try await supabase.database
                .from(Table.eventBookmarks.rawValue)
                .select()
                .eq("owner_id", value: ownerId)
                .execute()
                .value
            
            let ids = eventBookmarks.map { $0.eventId }
            
            let result: [EventWithNicknameRes] = try await supabase.database
                .from(Table.events.rawValue)
                .select(
                    """
                    id,
                    title,
                    date,
                    image_urls,
                    member:owner_id(username),
                    schedule_type
                    """
                )
                .in("id", value: ids)
                .order("created_at", ascending: false)
                .execute()
                .value
            return result
        } catch {
            print("fetchBookmarkedEvents - supabase error")
            return nil
        }
    }
    
    func fetchEventPicks() async -> [EventWithNicknameRes]? {
        do {
            let eventPicks: [EventPicksDTO] = try await supabase.database
                .from(Table.eventPicks.rawValue)
                .select()
                .limit(4)
                .execute()
                .value
            let ids = eventPicks.map{ $0.eventId }
            let result = await fetchEventsWithNicknameRes(by: ids)
            return result
        } catch {
            print("fetchEventPicks - supabase error")
            return nil
        }
    }
        
    private func fetchEventsWithNicknameRes(by ids: [String]) async -> [EventWithNicknameRes]? {
        do {
            let result: [EventWithNicknameRes] = try await supabase.database
                .from(Table.events.rawValue)
                .select(
                    """
                    id,
                    title,
                    date,
                    image_urls,
                    member:owner_id(username),
                    schedule_type,
                    owner_id
                    """
                )
                .in("id", value: ids)
                .order("created_at", ascending: false)
                .limit(4)
                .execute()
                .value
            return result
        } catch {
            print("fetchEventsWithNicknameRes - supabase error")
            return nil
        }
    }
    
    func updateEvent(_ event: EventToUpdate) async -> Bool {
        do {
            let response = try await supabase.database
                .from(Table.events.rawValue)
                .update(
                    event
                )
                .eq("id", value: event.id)
                .execute()
            return response.status == 200
        } catch {
            print("updateEvent - supabase error")
            return false
        }
    }
    
    func uploadImage(table: Table, pathName: String, data: Data) async -> Bool {
        do {
            try await supabase.storage
                .from(table.rawValue)
                .upload(
                    path: pathName,
                    file: data,
                    options: FileOptions(
                        cacheControl: "3600",
                        contentType: "image/jpeg",
                        upsert: false
                    )
                )
            return true
        } catch {
            print("uploadImage - supabase error")
            return false
        }
    }
    
    func deleteEvent(id: String) async -> Bool {
        do {
            let response = try await supabase.database
                .from(Table.events.rawValue)
                .delete()
                .eq("id", value: id)
                .execute()
            return response.status == 200
        } catch {
            print("deleteEvent - supabase error")
            return false
        }
    }
    
    func fetchHouseByOwnerId(_ ownerId: String) async -> HouseResponse? {
        do {
            let result: HouseResponse = try await supabase.database
                .from(Table.houses.rawValue)
                .select()
                .eq("owner_id", value: ownerId)
                .limit(1)
                .single()
                .execute()
                .value
            return result
        } catch {
            print("fetchHouseByOwnerId - supabase error")
            return nil
        }
    }
    
    func fetchHouses(from: Int = 0, to: Int = 3) async -> [HouseResponse]?  {
        do {
            let result: [HouseResponse] = try await supabase.database
                .from(Table.houses.rawValue)
                .select()
                .order("created_at", ascending: false)
                .range(from: from, to: to)
                .execute()
                .value
            return result
        } catch {
            print("fetchHouses - supabase error")
            return nil
        }
    }
    
    func fetchHouses(by category: HouseCategory, from: Int = 0, to: Int = 3) async -> [HouseResponse]? {
        do {
            let result: [HouseResponse] = try await supabase.database
                .from(Table.houses.rawValue)
                .select()
                .eq("category", value: category.rawValue)
                .order("created_at", ascending: false)
                .range(from: from, to: to)
                .execute()
                .value
            return result
        } catch {
            print("fetchHouses by category - supabase error")
            return nil
        }
    }
    
    func fetchHouses(by ownerId: String) async -> [HouseResponse]? {
        do {
            let result: [HouseResponse] = try await supabase.database
                .from(Table.houses.rawValue)
                .select()
                .eq("owner_id", value: ownerId)
                .order("created_at", ascending: false)
                .execute()
                .value
            return result
        } catch {
            print("fetchHouses by ownerId - supabase error")
            return nil
        }
    }
    
    func fetchHouseDetail(id: String) async -> HouseDetailResponse? {
        do {
            let res: HouseDetailResponse = try await supabase.database
                .from(Table.houses.rawValue)
                .select(
                    """
                    id,
                    name,
                    category,
                    title,
                    content,
                    image_urls,
                    cover_image_index,
                    domestic,
                    location,
                    owner:owner_id(username, member_type, profile_photo),
                    created_at,
                    updated_at,
                    owner_id,
                    detailed_location,
                    display_type
                    """
                )
                .eq("id", value: id)
                .limit(1)
                .single()
                .execute()
                .value
            return res
        } catch {
            print("fetchHouseDetail - supabase error")
        }
        return nil
    }
    
    func fetchHousePicks() async -> [HouseWithNicknameRes]?  {
        do {
            let housePicks: [HousePicksDTO] = try await supabase.database
                .from(Table.housePicks.rawValue)
                .select()
                .limit(4)
                .execute()
                .value
            let ids = housePicks.map{ $0.houseId }
            let result: [HouseWithNicknameRes] = try await supabase.database
                .from(Table.houses.rawValue)
                .select(
                    """
                    id,
                    category,
                    image_urls,
                    cover_image_index,
                    member:owner_id(username),
                    owner_id
                    """
                )
                .in("id", value: ids)
                .order("created_at", ascending: false)
                .limit(4)
                .execute()
                .value
            return result
        } catch {
            print("fetchHousePicks - supabase error")
            return nil
        }
    }
    
    func fetchHouseCommentsCount(houseId: String) async -> Int {
        do {
            let count = try await supabase.database
                .from(Table.houseComments.rawValue)
                .select("*", head: true, count: .exact)
                .eq("house_id", value: houseId)
                .execute()
                .count
            return count ?? 0
        } catch {
            print("fetchHouseCommentsCount - supabase error")
            return 0
        }
    }
    
    func fetchHouseComments(houseId: String) async -> [HouseCommentWithMemberRes]? {
        do {
            let res: [HouseCommentWithMemberRes] = try await supabase.database
                .from(Table.houseComments.rawValue)
                .select(
                    """
                    id,
                    content,
                    created_at,
                    updated_at,
                    house_id,
                    writer_id,
                    parent_comment_id,
                    member:writer_id(username, member_type, profile_photo)
                    """
                )
                .eq("house_id", value: houseId)
                .order("created_at", ascending: false)
                .execute()
                .value
            return res
        } catch {
            print("fetchHouseComments - supabase error")
        }
        return nil
    }
    
    func fetchHouseOwner(id: String) async -> HouseOwnerResponse? {
        do {
            let result: HouseOwnerResponse = try await supabase.database
                .from(Table.members.rawValue)
                .select(
                    """
                    id, member_type, username, profile_photo
                    """
                )
                .eq("id", value: id)
                .limit(1)
                .single()
                .execute()
                .value
            return result
        } catch {
            print("fetchHouseOwner - supabase error")
            return nil
        }
    }
    
    func fetchMemberWithInviter(id: String) async -> MemberWithInviterRes? {
        do {
            let result: MemberWithInviterRes = try await supabase.database
                .from(Table.members.rawValue)
                .select(
                    """
                    id,
                    name,
                    username,
                    gender,
                    birthday,
                    member_status,
                    created_at,
                    member_type,
                    login_id,
                    phone_no,
                    sns_url,
                    profile_photo,
                    updated_at,
                    inviter_id,
                    inviter:inviter_id(username)
                    """
                )
                .eq("id", value: id)
                .limit(1)
                .single()
                .execute()
                .value
            return result
        } catch {
            print("fetchMember - supabase error")
            return nil
        }
    }
    
    func fetchMembers() async -> [MemberResponse]? {
        do {
            let result: [MemberResponse] = try await supabase.database
                .from(Table.members.rawValue)
                .select()
                .execute()
                .value
            return result
        } catch {
            print("fetchMembers - supabase error")
            return nil
        }
    }
    
    func fetchInvitation(with code: String) async -> InvitationResponse? {
        await print("supabase.database.configuration.url", supabase.database.configuration.url)
        do {
            let res: InvitationResponse = try await supabase.database
                .from(Table.invitations.rawValue)
                .select()
                .eq("code", value: code)
                .limit(1)
                .single()
                .execute()
                .value
            return res
        } catch {
            print("fetchInvitation - supabase error")
            return nil
        }
    }
    
    func fetchInvitations(by inviterId: String) async -> [InvitationResponse] {
        do {
            let res: [InvitationResponse] = try await supabase.database
                .from(Table.invitations.rawValue)
                .select()
                .in("status", value: ["S", "J"])
                .match(["inviter_id" : inviterId])
                .limit(2)
                .execute()
                .value
            return res
        } catch {
            print("fetchInvitations by inviterId - supabase error")
            return []
        }
    }
    
    func updateStatusToSignupComplete(code: String) async {
        do {
            try await supabase.database
                .from(Table.invitations.rawValue)
                .update(["status": "J"])
                .eq("code", value: code)
                .execute()
        } catch {
            print("updateStatus - supabase error")
        }
    }
    
    func insertInvitations(_ invitation: InvitationResponse) async -> Bool {
        do {
            let response = try await supabase.database
                .from(Table.invitations.rawValue)
                .insert(invitation)
                .execute()
            return true
        } catch {
            print("insertInvitations - supabase error")
            return false
        }
    }
    
    func deleteInvitations(by inviteeEmail: String) async {
        do {
            try await supabase.database
                .from(Table.invitations.rawValue)
                .delete()
                .eq("invitee_email", value: inviteeEmail)
                .execute()
        } catch {
            print("deleteMember - supabase error")
        }
    }
   
    func insertMember(_ member: MemberResponse) async throws {
        try await supabase.database
            .from(Table.members.rawValue)
            .insert(member)
            .execute()
    }
    
    func insertWaiting(_ wating: Waiting) async throws {
        try await supabase.database
            .from(Table.waitings.rawValue)
            .insert(wating)
            .execute()
    }
    
    func fetchMember(id: String) async -> MemberResponse? {
        do {
            let member: MemberResponse = try await supabase.database
                .from(Table.members.rawValue)
                .select()
                .eq("id", value: id)
                .limit(1)
                .single()
                .execute()
                .value
            return member
        } catch {
            print("fetchMember by id - supabase error")
            return nil
        }
    }
    
    func fetchMember(by loginId: String) async -> MemberResponse? {
        do {
            let member: MemberResponse = try await supabase.database
                .from(Table.members.rawValue)
                .select()
                .eq("login_id", value: loginId)
                .limit(1)
                .single()
                .execute()
                .value
            return member
        } catch {
            print("fetchMember by loginId - supabase error")
            return nil
        }
    }
    
    func fetchMemberId(by loginId: String) async -> String? {
        do {
            let member: MemberResponse = try await supabase.database
                .from(Table.members.rawValue)
                .select("id")
                .eq("login_id", value: loginId)
                .limit(1)
                .single()
                .execute()
                .value
            return member.id
        } catch {
            print("fetchMemberId - supabase error")
            return nil
        }
    }
    
    func fetchLoginId(by id: String) async -> String? {
        do {
            let member: MemberResponse = try await supabase.database
                .from(Table.members.rawValue)
                .select("login_id")
                .eq("id", value: id)
                .limit(1)
                .single()
                .execute()
                .value
            return member.loginId
        } catch {
            print("fetchLoginId - supabase error")
            return nil
        }
    }
    
    func updateMember(id: String, username: String) async -> Bool {
        do {
            let response = try await supabase.database
                .from(Table.members.rawValue)
                .update(["username": username])
                .eq("id", value: id)
                .execute()
            return response.status == 200
        } catch {
            print("updateMember - supabase error")
            return false
        }
    }
    
    func updateMember(_ member: MemberToUpdate) async -> Bool {
        do {
            let response = try await supabase.database
                .from(Table.members.rawValue)
                .update(member)
                .eq("id", value: member.id)
                .execute()
            return response.status == 200
        } catch {
            print("updateMember - supabase error")
            return false
        }
    }
    
    func deleteMember(id: String) async {
        do {
            try await supabase.database
                .from(Table.members.rawValue)
                .delete()
                .eq("id", value: id)
                .execute()
        } catch {
            print("deleteMember - supabase error")
        }
    }
    
    func isUsernameExisting(_ username: String) async -> Bool {
        do {
            let member: MemberResponse = try await supabase.database
                .from(Table.members.rawValue)
                .select("id")
                .eq("username", value: username)
                .limit(1)
                .single()
                .execute()
                .value
            return (member.id != nil)
        } catch {
            print("isUsernameExisting - supabase error")
            return false
        }
    }
    
    func userInfo() async -> User? {
        do {
            let session = try await supabase.auth.session
            return session.user
        } catch {
            print("userInfo - unknown error")
            return nil
        }
    }
    
    func isSignedIn() async -> Bool {
        do {
            guard let id = await NetworkService.shared.userInfo()?.id.uuidString else { return false }
            let response = try await supabase.database
                .from(Table.members.rawValue)
                .select()
                .eq("id", value: id)
                .limit(1)
                .single()
                .execute()
            return response.status == 200
        } catch {
            print("isMemberExsting - supabase error")
        }
        return false
    }
    
    func supabaseSignOut() {
        Task {
            do {
                try await supabase.auth.signOut()
            } catch {
                print("supabaseSignOut - supabase error")
            }
        }
    }
    
    func insertEventComments(comment: EventComment, eventOwnerId: String) async throws {
        try await supabase.database
            .from(Table.eventComments.rawValue)
            .insert(comment)
            .execute()
        guard let actorId = await NetworkService.shared.userInfo()?.id.uuidString else { return }
        let actorNickname = await fetchUsername(id: actorId)
        let notification = NotificationDTO(id: UUID().uuidString, createdAt: Date(), read: false, type: AlarmType.eventComments.rawValue, ownerId: eventOwnerId, actorId: actorId, actorUsername: actorNickname, houseId: nil, houseCommentId: nil, eventId: comment.eventId, eventCommentId: comment.id)
        await insertNotifications(notification)
        await insertBookmarksEventComments(eventId: comment.eventId, commentId: comment.id, actorId: actorId, actorNickname: actorNickname)
    }
    
    func insertHouseComments(comment: HouseComment, houseOwnerId: String) async throws {
        try await supabase.database
            .from(Table.houseComments.rawValue)
            .insert(comment)
            .execute()
        guard let actorId = await NetworkService.shared.userInfo()?.id.uuidString else { return }
        let actorNickname = await fetchUsername(id: actorId)
        let notification = NotificationDTO(id: UUID().uuidString, createdAt: Date(), read: false, type: AlarmType.houseComments.rawValue, ownerId: houseOwnerId, actorId: actorId, actorUsername: actorNickname, houseId: comment.houseId, houseCommentId: comment.id, eventId: nil, eventCommentId: nil)
        await insertNotifications(notification)
    }
    
    func deleteEventComment(id: String) async -> Bool {
        do {
            let response = try await supabase.database
                .from(Table.eventComments.rawValue)
                .delete()
                .eq("id", value: id)
                .execute()
            return response.status == 200
        } catch {
            print("deleteEventComment - supabase error")
            return false
        }
    }
    
    func deleteHouseComment(id: String) async -> Bool {
        do {
            let response = try await supabase.database
                .from(Table.houseComments.rawValue)
                .delete()
                .eq("id", value: id)
                .execute()
            return response.status == 200
        } catch {
            print("deleteHouseComment - supabase error")
            return false
        }
    }
    
    func fetchEventBookmark(memberId: String, eventId: String) async -> EventBookmark? {
        do {
            let eventBookmark: EventBookmark = try await supabase.database
                .from(Table.eventBookmarks.rawValue)
                .select()
                .match(["owner_id": memberId, "event_id": eventId])
                .limit(1)
                .single()
                .execute()
                .value
            return eventBookmark
        } catch {
            print("fetchEventBookmark - supabase error")
        }
        return nil
    }
    
    func deleteEventBookmark(memberId: String, eventId: String) async {
        do {
            try await supabase.database
                .from(Table.eventBookmarks.rawValue)
                .delete()
                .match(["owner_id": memberId, "event_id": eventId])
                .execute()
            
            //NotificationCenter.default.post(name: .eventBookmarkChanged, object: self)
        } catch {
            print("deleteEventBookmark - supabase error")
        }
    }
    
    func insertEventBookmark(_ eventBookmark: EventBookmark, eventOwnerId: String) async {
        do {
            try await supabase.database
                .from(Table.eventBookmarks.rawValue)
                .insert(eventBookmark)
                .execute()
            
            //NotificationCenter.default.post(name: .eventBookmarkChanged, object: self)
        } catch {
            print("insertEventBookmark - supabase error")
            return
        }
        guard let actorId = await NetworkService.shared.userInfo()?.id.uuidString else { return }
        let actorNickname = await fetchUsername(id: actorId)
        let notification = NotificationDTO(id: UUID().uuidString, createdAt: Date(), read: false, type: AlarmType.bookmark.rawValue, ownerId: eventOwnerId, actorId: actorId, actorUsername: actorNickname, houseId: nil, houseCommentId: nil, eventId: eventBookmark.eventId, eventCommentId: nil)
        await insertNotifications(notification)
    }
    
    func fetchUsername(id: String) async -> String {
        do {
            let member: MemberResponse = try await supabase.database
                .from(Table.members.rawValue)
                .select()
                .eq("id", value: id)
                .limit(1)
                .single()
                .execute()
                .value
            return member.username ?? "알수없음"
        } catch {
            print("fetchUsername - supabase error")
            return "알수없음"
        }
    }
    
    func insertReport(_ report: Report) async throws {
        try await supabase.database
            .from(Table.reports.rawValue)
            .insert(report)
            .execute()
    }
    
    func fetchNotifications(ownerId: String, from: Int = 0, to: Int = 9) async -> [NotificationDTO]? {
        do {
            let notifications: [NotificationDTO] = try await supabase.database
                .from(Table.notifications.rawValue)
                .select()
                .eq("owner_id", value: ownerId)
                .range(from: from, to: to)
                .order("created_at", ascending: false)
                .execute()
                .value
            return notifications
        } catch {
            print("fetchNotifications - supabase error")
            return nil
        }
    }
    
    func insertBookmarksEventComments(eventId: String, commentId: String, actorId: String, actorNickname: String) async {
        guard let res = await fetchEventBookMarks(eventId: eventId) else { return }
        for bookmark in res.bookmarks {
            if bookmark.ownerId.lowercased() != actorId.lowercased() {
                let notification = NotificationDTO(id: UUID().uuidString, createdAt: Date(), read: false, type: AlarmType.bookmarkEventComments.rawValue, ownerId: bookmark.ownerId, actorId: actorId, actorUsername: actorNickname, houseId: nil, houseCommentId: nil, eventId: eventId, eventCommentId: commentId)
                await insertNotifications(notification)
            }
        }
    }

    func fetchEventBookMarks(eventId: String) async -> EventBookmarks? {
        do {
            let result: EventBookmarks = try await supabase.database
                .from("events")
                .select("""
                    id,
                    bookmarks:event_bookmarks(*)
                """)
                .eq("id", value: eventId)
                .limit(1)
                .single()
                .execute()
                .value
            return result
        } catch {
            print("fetchEventBookMarks - supabase error")
            return nil
        }
    }
    
    private func insertNotifications(_ notification: NotificationDTO) async {
        do {
            try await supabase.database
                .from(Table.notifications.rawValue)
                .insert(notification)
                .execute()
        } catch {
            print("insertNotifications - supabase error")
        }
    }
    
    func checkUnreadNotifications(ownerId: String) async -> Bool {
        do {
            if let count = try await supabase.database
                .from(Table.notifications.rawValue)
                .select("*", head: true, count: .exact)
                .match(["owner_id": ownerId, "read": false])
                .execute()
                .count, count > 0 {
                return true
            } else {
                return false
            }
        } catch {
            return false
        }
    }
    
    func readNotifications(ownerId: String) async {
        do {
            try await supabase.database
                .from(Table.notifications.rawValue)
                .update(["read": true])
                .eq("owner_id", value: ownerId)
                .execute()
        } catch {
            print("readNotifications - supabase error")
        }
    }
        
    func updateStatusToExpiredInvitations(inviterId: String) async {
        do {
            guard let invitations: [InvitationResponse] = try await supabase.database
                .from(Table.invitations.rawValue)
                .select()
                .eq("inviter_id", value: inviterId)
                .execute()
                .value else { return }
            
            let codes: [String] = invitations.filter { $0.createdAt.isDateMoreThanAWeek() }.map { $0.code }
            
            if codes.isEmpty { return }
            
            for code in codes {
                try await supabase.database
                    .from(Table.invitations.rawValue)
                    .update(["status": "E"])
                    .eq("code", value: code)
                    .execute()
            }
        } catch {
            print("updateStatus - supabase error")
        }
    }
    
    func insertBuddy(_ buddy: BuddyDTO) async {
        do {
            try await supabase.database
                .from(Table.buddies.rawValue)
                .insert(buddy)
                .execute()
        } catch {
            print("insertBuddy - supabase error")
        }
    }
    
    func invokeEmailEdgeFunction(email: String) async {
        do {
            try await supabase.functions
                .invoke(
                    EdgeFunctionName.invite.rawValue,
                    options: FunctionInvokeOptions(
                        body: ["email": email]
                    )
                )
        } catch FunctionsError.httpError(let code, let data) {
            print("Function returned code \(code) with response \(String(data: data, encoding: .utf8) ?? "")")
        } catch FunctionsError.relayError {
            print("Relay error")
        } catch {
            print("Unknown error: \(error.localizedDescription)")
        }
    }
    
    func fetchBlockedMembers<T: Decodable>(reporterId: String) async -> [T] {
        do {
            let result: [T] = try await supabase.database
                .from(Table.blockedMembers.rawValue)
                .select()
                .eq("reporter_id", value: reporterId)
                .execute()
                .value
            return result
        } catch {
            print("fetchBlockedMembers - supabase error")
            return []
        }
    }

    func insertBlockedMember(_ blockedMember: BlockedMemberDTO) async -> Bool {
        do {
            try await supabase.database
                .from(Table.blockedMembers.rawValue)
                .insert(blockedMember)
                .execute()
            return true
        } catch {
            print("insertBlockedMember - supabase error")
            return false
        }
    }
    
    func deleteBlockedMember(reporterId: String, blockedMemberId: String) async -> Bool {
        do {
            try await supabase.database
                .from(Table.blockedMembers.rawValue)
                .delete()
                .match(["reporter_id": reporterId, "blocked_member_id": blockedMemberId])
                .execute()
            return true
        } catch {
            print("deleteBlockedMember - supabase error")
            return false
        }
    }
}
