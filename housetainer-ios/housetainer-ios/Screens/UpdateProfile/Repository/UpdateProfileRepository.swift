//
//  UpdateProfileRepository.swift
//  housetainer-ios
//
//  Created by 김수아 on 3/17/24.
//

import Foundation
import Supabase
import KakaoSDKAuth
import KakaoSDKUser

enum UpdateProfileError: Error{
    case notFound
    case underlying(Error)
}

protocol UpdateProfileRepository{
    func requestUser() async throws -> UserProfile?
    
    @discardableResult
    func updateUser(
        gender: Gender?,
        birthday: Foundation.Date?,
        profileRef: ImageReference?
    ) async throws -> Bool
    
    func logout() async throws
    
    func withdrawal(inviteeEmail: String) async
}

struct UpdateProfileRepositoryImpl: UpdateProfileRepository{
    func requestUser() async throws -> UserProfile? {
        guard let userId = await NetworkService.shared.userInfo()?.id.uuidString else { return nil }
        guard let member = await NetworkService.shared.fetchMember(id: userId) else { return nil }
        return UserProfile(id: member.id ?? "", memberType: MemberType(rawValue: member.memberType!) ?? .normal, email: member.loginId ?? "", username: member.username ?? "", gender: Gender(rawValue: member.gender ?? "M"), birthday: Date(date: member.birthday ?? "") , profileRef: URL(string: member.profileUrl ?? "").map { .url($0) } )
    }

    func updateUser(
        gender: Gender? = nil,
        birthday: Foundation.Date? = nil,
        profileRef: ImageReference? = nil
    ) async throws -> Bool {
        guard let userId = await NetworkService.shared.userInfo()?.id.uuidString.lowercased() else { return false }
        var processedProfileRef = profileRef
        if let profileRef, !profileRef.isRemoteResource, let profileData = await profileRef.data{
            let path = "profile_photo/\(userId)/\(Date().timeIntervalSince1970).jpg"
            _ = await NetworkService.shared.uploadImage(table: .member, pathName: path, data: profileData)
            processedProfileRef = .url(URL(string: "\(Url.imageBase("member"))/\(path)")!)
        }        
        let isUpdated = await NetworkService.shared.updateMember(MemberToUpdate(id: userId, profilePhoto: processedProfileRef?.absoluteString ?? "", gender: gender?.rawValue ?? "M", birthday: birthday ?? Date()))
        return isUpdated
    }

    func logout() async throws {
        NetworkService.shared.supabaseSignOut()
        kakaoSignout()
    }
    
    func withdrawal(inviteeEmail: String) async {
        guard let userId = await NetworkService.shared.userInfo()?.id.uuidString else { return }
        await NetworkService.shared.deleteMember(id: userId)
        await NetworkService.shared.deleteInvitations(by: inviteeEmail)
        NetworkService.shared.supabaseSignOut()
        kakaoSignout()
    }
    
    private func kakaoSignout() {
        if AuthApi.hasToken() {
            UserApi.shared.logout { error in
                if error != nil {
                    print("kakao signout error")
                }
            }
        }
    }
}
