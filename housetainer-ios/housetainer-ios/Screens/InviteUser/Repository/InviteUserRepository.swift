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
        guard let inviterId = await NetworkService.shared.userInfo()?.id.uuidString else { return false }
        let invitation = InvitationResponse(createdAt: Date(), code: (0..<8).map{ _ in String(Int.random(in: 0..<9)) }.joined(separator: ""), inviterId: inviterId, inviteeEmail: email, inviteeName: name, status: "S")
        let isInserted = await NetworkService.shared.insertInvitations(invitation)
        return isInserted
    }
}

struct InviteUserRepositoryMock: InviteUserRepository{
    func requestInvite(name: String, email: String) async throws -> Bool {
        true
    }
}
