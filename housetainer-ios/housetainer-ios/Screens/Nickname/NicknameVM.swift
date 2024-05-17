//
//  NicknameVM.swift
//  housetainer-ios
//
//  Created by 이주상 on 1/26/24.
//

import Foundation
import Combine
import Supabase

final class NicknameVM {
    let inviterId: String?
    let isMemberRegistered = CurrentValueSubject<Bool?, Never>(nil)
    let isNicknameDuplicate = CurrentValueSubject<Bool?, Never>(nil)
    
    init(inviterId: String?) {
        self.inviterId = inviterId
    }
}

extension NicknameVM {
    func registerMember(nickname: String) async {
        do {
            let user = await NetworkService.shared.userInfo()
            if let id = user?.id.uuidString, let loginId = user?.email {
                let member = MemberResponse(id: id, memberStatus: "A", createdAt: Date(), memberType: nil, name: nil, loginId: loginId, username: nickname, gender: nil, birthday: nil, phoneNumber: nil, snsUrl: nil, profileUrl: nil, updatedAt: Date(), inviterId: inviterId)
                try await NetworkService.shared.insertMember(member)
                let buddy = BuddyDTO(ownerId: inviterId, buddyId: id, createdAt: Date())
                await NetworkService.shared.insertBuddy(buddy)
            }
            isMemberRegistered.send(true)
        } catch {
            print("This nickname is already in use")
            isNicknameDuplicate.send(true)
        }
    }
}
