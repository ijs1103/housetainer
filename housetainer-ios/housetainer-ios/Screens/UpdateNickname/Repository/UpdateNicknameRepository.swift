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
        guard let userId = await NetworkService.shared.userInfo()?.id.uuidString else { 
            return UserNickname(username: "")
        }
        let username = await NetworkService.shared.fetchUsername(id: userId)
        return UserNickname(username: username)
    }
    
    func updateNickname(nickname: String) async throws -> Bool {
        guard !(try await existNickname(nickname: nickname)) else{ throw UpdateNicknameError.duplicatedNickname }
        guard let userId = await NetworkService.shared.userInfo()?.id.uuidString else { return false }
        let isUpdated = await NetworkService.shared.updateMember(id: userId, username: nickname)
        return isUpdated
    }
    
    private func existNickname(nickname: String) async throws -> Bool{
        let isUsernameExisting = await NetworkService.shared.isUsernameExisting(nickname)
        return isUsernameExisting
    }
}

struct UpdateNicknameRepositoryMock: UpdateNicknameRepository{
    func requestUser() async throws -> UserNickname {
        UserNickname(
            username: "nickname"
        )
    }
    
    func updateNickname(nickname: String) async throws -> Bool {
        true
    }
}
