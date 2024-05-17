//
//  InviteVM.swift
//  housetainer-ios
//
//  Created by 이주상 on 1/17/24.
//

import Combine
import Supabase

final class InviteVM {
    let isCodeExpired = CurrentValueSubject<Bool?, Never>(nil)
    let isInvitationExisting = CurrentValueSubject<Bool?, Never>(nil)
    let inviterId = CurrentValueSubject<String?, Never>(nil)
}

extension InviteVM {
    func verifyInvitationCode(with code: String) async {
        guard let invitation = await NetworkService.shared.fetchInvitation(with: code) else {
            isInvitationExisting.send(false)
            return
        }
        inviterId.send(invitation.inviterId)
        // 만료 되었으면(J : 가입완료, E : 기간만료) 뷰컨에 만료상태를 전달
        // 만료 안되었으면 만료상태로 update
        let isExpired = ["J", "E"].contains(invitation.status)
        if isExpired {
            isCodeExpired.send(true)
        } else {
            await NetworkService.shared.updateStatusToSignupComplete(code: code)
            isCodeExpired.send(false)
        }
    }
}
