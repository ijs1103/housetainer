//
//  InviteVM.swift
//  housetainer-ios
//
//  Created by 이주상 on 1/17/24.
//

import Combine
import Supabase
import KakaoSDKAuth
import KakaoSDKUser
import NaverThirdPartyLogin

final class InviteVM {
    private let client = SupabaseClient(supabaseURL: Env.supabaseURL, supabaseKey: Env.supabaseKey)
    let isCodeExpired = CurrentValueSubject<Bool?, Never>(nil)
    let isInvitationExisting = CurrentValueSubject<Bool?, Never>(nil)
}

extension InviteVM {
    func verifyInvitationCode(with code: String, isProviderApple: Bool = false) async {
        let invitation: InvitationResponse?
        // 애플로그인이면 이메일은 생략하고 invitations 데이터를 fetch
        if isProviderApple {
            invitation = await NetworkService.shared.fetchInvitationWithCode(code)
        } else {
            guard let email = await NetworkService.shared.userInfo()?.email else { return }
            invitation = await NetworkService.shared.fetchInvitationWithCodeAndEmail(code, email)
        }
        
        guard let fetchedInvitation = invitation else {
            isInvitationExisting.send(false)
            return
        }
        // 만료 되었으면(J : 가입완료, E : 기간만료) 뷰컨에 만료상태를 전달
        // 만료 안되었으면 만료상태로 update
        let isExpired = ["J", "E"].contains(fetchedInvitation.status)
        if isExpired {
            isCodeExpired.send(true)
        } else {
            await NetworkService.shared.updateStatusToSignupComplete(code: code)
            isCodeExpired.send(false)
        }
    }
    
    func kakaoNaverSignOut() {
        if let loginInstance = NaverThirdPartyLoginConnection.getSharedInstance() {
            loginInstance.resetToken()
        }
        if AuthApi.hasToken() {
            UserApi.shared.logout { error in
                if error != nil {
                    print("kakao signout error")
                }
            }
        }
    }
}
