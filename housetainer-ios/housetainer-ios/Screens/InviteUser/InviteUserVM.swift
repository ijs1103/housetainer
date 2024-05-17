//
//  InviteUserVM.swift
//  housetainer-ios
//
//  Created by 김수아 on 2/12/24.
//

import Foundation
import Combine

extension NSNotification.Name{
    static let userInvited = Self(rawValue: "userInvited")
}

extension InviteUserVM{
    static let userInfoKey = "model"
}

@MainActor
final class InviteUserVM{
    
    let isEmailValid = CurrentValueSubject<Bool?, Never>(nil)

    var inviteUserPublisher: AnyPublisher<InviteUser, Never>{
        inviteUserSubject.eraseToAnyPublisher()
    }
    
    init(repository: InviteUserRepository = InviteUserRepositoryImpl()){
        self.repository = repository
    }
    // MARK: - Private
    private let repository: InviteUserRepository
    private let inviteUserSubject = CurrentValueSubject<InviteUser, Never>(.init())
}

extension InviteUserVM {
    
    func emailValidCheck(_ email: String) {
        let emailValid = RegexHelper.matchesRegex(email, regex: Regex.email)
        isEmailValid.send(emailValid)
    }
    
    func updateName(_ name: String){
        var oldInviteUser = inviteUserSubject.value
        oldInviteUser.name = name
        oldInviteUser.canUpdate = !oldInviteUser.name.isEmpty && !oldInviteUser.email.isEmpty
        inviteUserSubject.send(oldInviteUser)
    }
    
    func updateEmail(_ email: String){
        var oldInviteUser = inviteUserSubject.value
        oldInviteUser.email = email
        oldInviteUser.canUpdate = !oldInviteUser.name.isEmpty && !oldInviteUser.email.isEmpty
        inviteUserSubject.send(oldInviteUser)
    }
    
    func requestInvite(name: String, email: String) {
        Task.detached(priority: .userInitiated) { [weak self] in
            guard let self else{ return }
            
            var oldInviteUser = inviteUserSubject.value
            guard !oldInviteUser.isCompleted else{ return }
            do{
                await NetworkService.shared.invokeEmailEdgeFunction(email: email)
                oldInviteUser.isCompleted = true
                inviteUserSubject.send(oldInviteUser)
                
                await NotificationCenter.default.post(name: .userInvited, object: self, userInfo: [
                    InviteUserVM.userInfoKey: oldInviteUser
                ])
            }catch{
                print(error)
            }
        }
    }
    
    
}
