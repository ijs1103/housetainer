//
//  UpdateProfileRepository.swift
//  housetainer-ios
//
//  Created by 김수아 on 3/17/24.
//

import Foundation
import Supabase
import Apollo
import Interstyle

enum UpdateProfileError: Error{
    case notFound
    case underlying(Error)
}

protocol UpdateProfileRepository{
    func requestUser() async throws -> UserProfile
    
    @discardableResult
    func updateUser(
        gender: Gender?,
        birthday: Foundation.Date?,
        profileRef: ImageReference?
    ) async throws -> Bool
}

struct UpdateProfileRepositoryImpl: UpdateProfileRepository{
    func requestUser() async throws -> UserProfile {
        let session = try await SupabaseClient.shared.auth.session
        do{
            let data = try await ApolloClient.shared.fetch(query: UserProfileQuery(id: session.user.id.uuidString))
            guard let data = data else{ throw UpdateProfileError.notFound }
            guard let user = data.userProfile?.edges.first?.node else{ throw UpdateProfileError.notFound }
            
            return UserProfile(
                id: user.id,
                memberType: MemberType(rawValue: user.memberType.ifNil(then: "")).ifNil(then: .normal),
                email: user.email.ifNil(then: ""),
                nickname: user.nickname.ifNil(then: ""),
                gender: Gender(rawValue: user.gender.ifNil(then: "")),
                birthday: Date(date: user.birthday.ifNil(then: "")),
                profileRef: URL(string: user.profileUrl.ifNil(then: "")).map{ .url($0) }
            )
        }catch{
            throw UpdateProfileError.underlying(error)
        }
    }

    func updateUser(
        gender: Gender? = nil,
        birthday: Foundation.Date? = nil,
        profileRef: ImageReference? = nil
    ) async throws -> Bool {
        let session = try await SupabaseClient.shared.auth.session
        var processedProfileRef = profileRef
        do{
            if let profileRef, !profileRef.isRemoteResource, let profileData = await profileRef.data{
                let path = "profile_photo/\(session.user.id.uuidString)/\(Date().timeIntervalSince1970).jpg"
                let fileOptions = FileOptions(contentType: "image/jpeg")
                try await SupabaseClient.shared.storage.from("member")
                    .upload(path: path, file: profileData, options: fileOptions)
                processedProfileRef = .url(URL(string: "\(Url.imageBase("member"))/\(path)")!)
            }
            
            let data = try await ApolloClient.shared.perform(mutation: UpdateUserProfileMutation(
                id: session.user.id.uuidString,
                profileUrl: .init(wrap: processedProfileRef?.absoluteString),
                gender: .init(wrap: gender?.rawValue),
                birthday: .init(wrap: birthday?.date())
            ))
            guard let data = data else{ throw UpdateProfileError.notFound }
            return data.userProfile.affectedCount != 0
        }catch{
            throw UpdateProfileError.underlying(error)
        }
    }
}

struct UpdateProfileRepositoryMock: UpdateProfileRepository{
    func requestUser() async throws -> UserProfile {
        UserProfile(
            id: "user",
            memberType: .housetainer,
            email: "user@example.com",
            nickname: "user_nickname",
            gender: .male,
            birthday: Foundation.Date(),
            profileRef: URL(string: "https://picsum.photos/200?id=0").map{ .url($0) }
        )
    }
    
    func updateUser(
        gender: Gender? = nil,
        birthday: Foundation.Date? = nil,
        profileRef: ImageReference? = nil
    ) async throws -> Bool {
        true
    }
}
