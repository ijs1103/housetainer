//
//  UpdateProfileVM.swift
//  housetainer-ios
//
//  Created by 김수아 on 1/15/24.
//

import Foundation
import Combine

@MainActor
final class UpdateProfileVM{
    var userProfilePublisher: AnyPublisher<UserProfile?, Never>{
        userProfileSubject.eraseToAnyPublisher()
    }
    
    init(repository: UpdateProfileRepository = UpdateProfileRepositoryImpl()){
        self.repository = repository
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
                userProfileSubject.send(oldUserProfile)
            }catch{
                print(error)
            }
        }
    }
    
    // MARK: - Private
    private let repository: UpdateProfileRepository
    private let userProfileSubject = CurrentValueSubject<UserProfile?, Never>(nil)
}

extension UpdateProfileVM{
    
}

