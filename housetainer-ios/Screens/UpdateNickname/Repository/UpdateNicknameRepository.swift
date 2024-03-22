//
//  UpdateNicknameRepository.swift
//  housetainer-ios
//
//  Created by 김수아 on 3/17/24.
//

import Foundation
import Apollo
import Interstyle
import Supabase

enum UpdateNicknameError: Error{
    case notFound
    case duplicatedNickname
    case underlying(Error)
}

protocol UpdateNicknameRepository{
    func requestUser() async throws -> UserNickname
    
    @discardableResult
    func updateNickname(nickname: String) async throws -> Bool
}

struct UpdateNicknameRepositoryImpl: UpdateNicknameRepository{
    func requestUser() async throws -> UserNickname {
        do{
            let session = try await SupabaseClient.shared.auth.session
            let data = try await ApolloClient.shared.fetch(query: UserNicknameQuery(
                id: session.user.id.uuidString
            ))
            guard let data = data else{ throw UpdateNicknameError.notFound }
            guard let user = data.userProfile?.edges.first?.node else{ throw UpdateNicknameError.notFound }
            return UserNickname(
                nickname: user.nickname.ifNil(then: "")
            )
        }catch{
            throw UpdateProfileError.underlying(error)
        }
    }
    
    func updateNickname(nickname: String) async throws -> Bool {
        guard !(try await existNickname(nickname: nickname)) else{ throw UpdateNicknameError.duplicatedNickname }
        do{
            let session = try await SupabaseClient.shared.auth.session
            let data = try await ApolloClient.shared.perform(mutation: UpdateUserNicknameMutation(
                id: session.user.id.uuidString,
                nickname: nickname
            ))
            guard let data = data else{ throw UpdateProfileError.notFound }
            return data.userProfile.affectedCount != 0
        }catch{
            throw UpdateProfileError.underlying(error)
        }
    }
    
    private func existNickname(nickname: String) async throws -> Bool{
        do{
            let session = try await SupabaseClient.shared.auth.session
            let data = try await ApolloClient.shared.fetch(query: ExistUserNicknameQuery(
                nickname: nickname
            ))
            guard let data = data else{ throw UpdateProfileError.notFound }
            guard let user = data.userProfile?.edges.first else{ return false }
            return user.node.id != session.user.id.uuidString
        }catch{
            throw UpdateProfileError.underlying(error)
        }
    }
}

struct UpdateNicknameRepositoryMock: UpdateNicknameRepository{
    func requestUser() async throws -> UserNickname {
        UserNickname(
            nickname: "nickname"
        )
    }
    
    func updateNickname(nickname: String) async throws -> Bool {
        true
    }
}
