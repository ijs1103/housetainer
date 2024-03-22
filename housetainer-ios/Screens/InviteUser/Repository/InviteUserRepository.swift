//
//  InviteUserRepository.swift
//  housetainer-ios
//
//  Created by 김수아 on 3/17/24.
//

import Foundation
import Supabase
import Apollo
import Interstyle

enum InviteUserError: Error{
    case notFound
    case underlying(Error)
}

protocol InviteUserRepository{
    @discardableResult
    func requestInvite(name: String, email: String) async throws -> Bool
}

struct InviteUserRepositoryImpl: InviteUserRepository{
    func requestInvite(name: String, email: String) async throws -> Bool {
        do{
            let session = try await SupabaseClient.shared.auth.session
            let data = try await ApolloClient.shared.perform(mutation: InviteUserMutation(
                ownerId: session.user.id.uuidString,
                name: name,
                email: email,
                code: (0..<6).map{ _ in String(Int.random(in: 0..<9)) }.joined(separator: ""),
                createdAt: Date().datetime()
            ))
            guard let data = data else{ throw InviteUserError.notFound }
            return data.inviteUser?.affectedCount != 0
        }catch{
            throw InviteUserError.underlying(error)
        }
    }
}

struct InviteUserRepositoryMock: InviteUserRepository{
    func requestInvite(name: String, email: String) async throws -> Bool {
        true
    }
}
