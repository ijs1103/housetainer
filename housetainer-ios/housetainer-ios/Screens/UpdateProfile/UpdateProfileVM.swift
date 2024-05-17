//
//  UpdateProfileVM.swift
//  housetainer-ios
//
//  Created by 김수아 on 1/15/24.
//

import Foundation
import Combine
import Supabase

extension NSNotification.Name{
    static let profileUpdated = Self(rawValue: "profileUpdated")
}

extension UpdateProfileVM{
    static let userInfoKey = "model"
}

@MainActor
final class UpdateProfileVM{
    var userProfilePublisher: AnyPublisher<UserProfile?, Never>{
        userProfileSubject.eraseToAnyPublisher()
    }
    
    init(repository: UpdateProfileRepository = UpdateProfileRepositoryImpl()){
        self.repository = repository
        
        NotificationCenter.default.addObserver(self, selector: #selector(didUpdateNickname(_:)), name: .nicknameUpdated, object: nil)
    }
    
    deinit{
        NotificationCenter.default.removeObserver(self)
    }
    
    func logout(completion: @escaping(@MainActor () -> Void)){
        Task.detached(priority: .userInitiated) { [weak self] in
            guard let self else{ return }
            do {
                try await repository.logout()
                await completion()
            } catch {
                print(error)
            }
        }
    }
    
    func withdrawal(completion: @escaping (@MainActor () -> Void)){
        Task.detached(priority: .userInitiated) { [weak self] in
            guard let self else{ return }
            guard let currentUserId = await NetworkService.shared.userInfo()?.id.uuidString.lowercased(), let inviteeEmail = await NetworkService.shared.fetchLoginId(by: currentUserId) else { return }
            await repository.withdrawal(inviteeEmail: inviteeEmail)
            await completion()
        }
    }
    
    func load() {
        Task.detached(priority: .userInitiated) { [weak self] in
            guard let self else{ return }
            do{
                let userProfile = try await repository.requestUser()
                userProfileSubject.send(userProfile)
            }catch{
                print(error)
            }
        }
    }
    
    func updateProfile(reference: ImageReference){
        guard var oldUserProfile = userProfileSubject.value else{ return }
        oldUserProfile.profileRef = reference
        oldUserProfile.canUpdate = true
        userProfileSubject.send(oldUserProfile)
    }
    
    func updateGender(_ gender: Gender?){
        guard var oldUserProfile = userProfileSubject.value else{ return }
        oldUserProfile.gender = gender
        oldUserProfile.canUpdate = true
        userProfileSubject.send(oldUserProfile)
    }
    
    func updateBirthday(_ birthday: Date?){
        guard var oldUserProfile = userProfileSubject.value else{ return }
        oldUserProfile.birthday = birthday
        oldUserProfile.canUpdate = true
        userProfileSubject.send(oldUserProfile)
    }
    
    func save(){
        Task.detached(priority: .userInitiated) { [weak self] in
            guard let self else{ return }
            guard var oldUserProfile = userProfileSubject.value else{ return }
            let gender = oldUserProfile.gender
            let birthday = oldUserProfile.birthday
            let profileRef = oldUserProfile.profileRef
            
            oldUserProfile.isLoading = true
            userProfileSubject.send(oldUserProfile)
            do{
                let _ = try await repository.updateUser(
                    gender: gender,
                    birthday: birthday,
                    profileRef: profileRef
                )
                oldUserProfile.gender = gender
                oldUserProfile.birthday = birthday
                oldUserProfile.profileRef = profileRef
                oldUserProfile.canUpdate = false
                oldUserProfile.isCompleted = true
                oldUserProfile.isLoading = false
                userProfileSubject.send(oldUserProfile)
                
                await NotificationCenter.default.post(name: .profileUpdated, object: self, userInfo: [
                    UpdateProfileVM.userInfoKey: oldUserProfile
                ])
            }catch{
                oldUserProfile.isLoading = false
                userProfileSubject.send(oldUserProfile)
                print(error)
            }
        }
    }
    
    // MARK: - Private
    private let repository: UpdateProfileRepository
    private let userProfileSubject = CurrentValueSubject<UserProfile?, Never>(nil)
    
    @objc private func didUpdateNickname(_ notification: NSNotification){
        guard var oldUserProfile = userProfileSubject.value, let model = notification.userInfo?[UpdateNicknameVM.userInfoKey] as? UserNickname else{ return }
        oldUserProfile.username = model.username
        userProfileSubject.send(oldUserProfile)
    }
}

extension UpdateProfileVM{
    
}

