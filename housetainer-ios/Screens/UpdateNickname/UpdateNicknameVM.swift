//
//  UpdateNicknameVM.swift
//  housetainer-ios
//
//  Created by 김수아 on 1/16/24.
//

import Foundation
import Combine

@MainActor
final class UpdateNicknameVM{
    var userNicknamePublisher: AnyPublisher<UserNickname?, Never>{
        userNicknameSubject.eraseToAnyPublisher()
    }
    var errorPublisher: AnyPublisher<String, Never>{
        errorSubject.eraseToAnyPublisher()
    }
    
    init(repository: UpdateNicknameRepository = UpdateNicknameRepositoryImpl()){
        self.repository = repository
    }
    
    func load(){
        Task.detached(priority: .userInitiated){ [weak self] in
            guard let self else{ return }
            do{
                let userNickname = try await repository.requestUser()
                userNicknameSubject.send(userNickname)
            }catch{
                print(error)
            }
        }
    }
    
    func updateNickname(_ nickname: String){
        guard var oldUserNickname = userNicknameSubject.value else{ return }
        oldUserNickname.nickname = nickname
        oldUserNickname.canUpdate = true
        userNicknameSubject.send(oldUserNickname)
    }
    
    func saveNickname(){
        Task.detached(priority: .userInitiated) { [weak self] in
            guard let self else{ return }
            guard var oldUserNickname = userNicknameSubject.value else{ return }
            errorSubject.send("")
            
            let nickname = oldUserNickname.nickname
            do{
                let _ = try await repository.updateNickname(nickname: nickname)
                oldUserNickname.nickname = nickname
                oldUserNickname.canUpdate = false
                userNicknameSubject.send(oldUserNickname)
            }catch UpdateNicknameError.duplicatedNickname{
                oldUserNickname.canUpdate = false
                userNicknameSubject.send(oldUserNickname)
                errorSubject.send("이미 사용중인 닉네임입니다.")
            }catch{
                print(error)
            }
        }
    }
    
    // MARK: - Private
    private let repository: UpdateNicknameRepository
    private let userNicknameSubject = CurrentValueSubject<UserNickname?, Never>(nil)
    private let errorSubject = CurrentValueSubject<String, Never>("")
}
