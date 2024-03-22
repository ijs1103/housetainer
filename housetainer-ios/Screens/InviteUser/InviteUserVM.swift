//
//  InviteUserVM.swift
//  housetainer-ios
//
//  Created by 김수아 on 2/12/24.
//

import Foundation
import Combine

@MainActor
final class InviteUserVM{
    var inviteUserPublisher: AnyPublisher<InviteUser, Never>{
        inviteUserSubject.eraseToAnyPublisher()
    }
    
    init(repository: InviteUserRepository = InviteUserRepositoryImpl()){
        self.repository = repository
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
    
    func requestInvite(){
        Task.detached(priority: .userInitiated) { [weak self] in
            guard let self else{ return }
            
            var oldInviteUser = inviteUserSubject.value
            guard !oldInviteUser.isCompleted else{ return }
            do{
                let _ = try await repository.requestInvite(name: oldInviteUser.name, email: oldInviteUser.email)
                oldInviteUser.isCompleted = true
                inviteUserSubject.send(oldInviteUser)
            }catch{
                print(error)
            }
        }
    }
    
    // MARK: - Private
    private let repository: InviteUserRepository
    private let inviteUserSubject = CurrentValueSubject<InviteUser, Never>(.init())
}
