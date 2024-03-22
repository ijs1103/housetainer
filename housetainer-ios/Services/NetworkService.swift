//
//  NetworkService.swift
//  Housetainer
//
//  Created by 이주상 on 2023/11/21.
//

import Supabase
import Foundation
import GoTrue

final class NetworkService {
    static let shared = NetworkService()
    private let supabase = SupabaseClient(supabaseURL: Env.supabaseURL, supabaseKey: Env.supabaseKey)
    
    private init() {}
    
    func fetchEventDetail(id: String) async -> EventDetailResponse? {
        do {
            let res: EventDetailResponse = try await supabase.database
                .from(Table.events.rawValue)
                .select(
                    """
                    id, title, member:member_id(nickname, member_type, profile_photo), detail, created_at,
                    file_name, member_id, related_link, schedule_type, date
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
                    member:writer_id(nickname, member_type, profile_photo)
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
    
    func fetchEvents() async -> [EventDetailResponse]? {
        do {
            let result: [EventDetailResponse] = try await supabase.database
                .from(Table.events.rawValue)
                .select(
                    """
                    id, title, member:member_id(nickname, member_type, profile_photo), detail, created_at,
                    file_name, member_id, related_link, schedule_type, date
                    """
                )
                .order("created_at", ascending: false)
                .execute()
                .value
            return result
        } catch {
            print("fetchEvents - supabase error")
            return nil
        }
    }
    
    func fetchMainEvents() async -> [EventDto]? {
        do {
            let result: [EventDto] = try await supabase.database
                .from(Table.events.rawValue)
                .select()
                .match(["schedule_type": "행사", "display_type": "Y"])
                .order("created_at", ascending: false)
                .limit(6)
                .execute()
                .value
            return result
        } catch {
            print("fetchMainEvents - supabase error")
            return nil
        }
    }
    
    func fetchRecentEvents() async -> [EventWithNicknameRes]? {
        do {
            let result: [EventWithNicknameRes] = try await supabase.database
                .from(Table.events.rawValue)
                .select(
                    """
                    id,
                    title,
                    date,
                    file_name,
                    member:member_id(nickname)
                    """
                )
                .order("created_at", ascending: false)
                .limit(4)
                .execute()
                .value
            return result
        } catch {
            print("fetchRecentEvents - supabase error")
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
    
    func uploadImage(pathName: String, data: Data) async -> Bool {
        do {
            try await supabase.storage
                .from(Table.events.rawValue)
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
    
    func fetchHouses() async -> [HouseResponse]?  {
        do {
            let result: [HouseResponse] = try await supabase.database
                .from(Table.houses.rawValue)
                .select()
                .execute()
                .value
            return result
        } catch {
            print("fetchHouses - supabase error")
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
                    imageURLs,
                    coverImageIndex,
                    domestic,
                    location,
                    owner:owner_id(nickname, member_type, profile_photo),
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
    
    func fetchRecentHouses() async -> [HouseWithNicknameRes]?  {
        do {
            let result: [HouseWithNicknameRes] = try await supabase.database
                .from(Table.houses.rawValue)
                .select(
                    """
                    id,
                    category,
                    imageURLs,
                    coverImageIndex,
                    member:owner_id(nickname)
                    """
                )
                .order("created_at", ascending: false)
                .limit(4)
                .execute()
                .value
            return result
        } catch {
            print("fetchRecentHouses - supabase error")
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
                    member:writer_id(nickname, member_type, profile_photo)
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
                    id, member_type, nickname, profile_photo
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
    
    func fetchInvitationWithCode(_ code: String) async -> InvitationResponse? {
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
            print("fetchInvitationWithCode - supabase error")
        }
        return nil
    }
    
    func fetchInvitationWithCodeAndEmail(_ code: String, _ email: String) async -> InvitationResponse? {
        do {
            let res: InvitationResponse = try await supabase.database
                .from(Table.invitations.rawValue)
                .select()
                .match(["code": code, "invitee_email": email])
                .limit(1)
                .single()
                .execute()
                .value
            return res
        } catch {
            print("getInvitationWithCodeAndEmail - supabase error")
        }
        return nil
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
    
    func insertMember(id: String, nickname: String, loginId: String) async throws {
        let member = MemberResponse(id: id, memberStatus: "A", createdAt: Date(), memberType: nil, name: nil, loginId: loginId, nickname: nickname, gender: nil, birthday: nil, phoneNumber: nil, snsUrl: nil, profileUrl: nil, updatedAt: Date())
        
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
    
    func fetchMemberWithLoginId(_ loginId: String) async throws -> MemberResponse? {
        let member: MemberResponse = try await supabase.database
            .from(Table.members.rawValue)
            .select()
            .eq("login_id", value: loginId)
            .limit(1)
            .single()
            .execute()
            .value
        return member
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
    
    func userInfo() async -> User? {
        do {
            let session = try await supabase.auth.session
            UserDefaults.standard.setValue(session.accessToken, forKey: "accessToken")
            return session.user
        } catch GoTrueError.sessionNotFound {
            UserDefaults.standard.setValue(nil, forKey: "accessToken")
            print("userInfo - session not found")
        } catch {
            print("userInfo - unknown error")
        }
        return nil
    }
    
    func isSignedIn() async -> Bool {
        let user = await NetworkService.shared.userInfo()
        return user != nil
    }
    
    func supabaseSignOut() {
        Task {
            do {
                try await supabase.auth.signOut()
                UserDefaults.standard.setValue(nil, forKey: "accessToken")
            } catch {
                print("supabaseSignOut - supabase error")
            }
        }
    }
    
    func insertEventComments(_ comment: EventComment) async throws {
        try await supabase.database
            .from(Table.eventComments.rawValue)
            .insert(comment)
            .execute()
    }
    
    func insertHouseComments(_ comment: HouseComment) async throws {
        try await supabase.database
            .from(Table.houseComments.rawValue)
            .insert(comment)
            .execute()
    }
    
    func fetchEventBookmark(memberId: String, eventId: String) async -> EventBookmark? {
        do {
            let eventBookmark: EventBookmark = try await supabase.database
                .from(Table.eventBookmarks.rawValue)
                .select()
                .match(["member_id": memberId, "event_id": eventId])
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
                .match(["member_id": memberId, "event_id": eventId])
                .execute()
        } catch {
            print("deleteEventBookmark - supabase error")
        }
    }
    
    func insertEventBookmark(_ eventBookmark: EventBookmark) async {
        do {
            try await supabase.database
                .from(Table.eventBookmarks.rawValue)
                .insert(eventBookmark)
                .execute()
        } catch {
            print("insertEventBookmark - supabase error")
        }
    }
}
