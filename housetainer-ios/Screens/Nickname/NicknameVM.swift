//
//  NicknameVM.swift
//  housetainer-ios
//
//  Created by 이주상 on 1/26/24.
//

import Combine
import Supabase

final class NicknameVM {
    private let client = SupabaseClient(supabaseURL: Env.supabaseURL, supabaseKey: Env.supabaseKey)
    let isMemberRegistered = CurrentValueSubject<Bool?, Never>(nil)
    let isNicknameDuplicate = CurrentValueSubject<Bool?, Never>(nil)
}

extension NicknameVM {
    func registerMember(nickname: String) async {
        do {
            let user = await NetworkService.shared.userInfo()
            if let id = user?.id.uuidString, let loginId = user?.email {
                try await NetworkService.shared.insertMember(id: id, nickname: nickname, loginId: loginId)
            }
            isMemberRegistered.send(true)
        } catch {
            print("This nickname is already in use")
            isNicknameDuplicate.send(true)
        }
    }
}
