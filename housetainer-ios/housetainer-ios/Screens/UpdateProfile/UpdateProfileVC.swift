//
//  UpdateProfileVC.swift
//  housetainer-ios
//
//  Created by 김수아 on 1/15/24.
//

import Foundation
import UIKit
import Combine
import Photos
import PhotosUI

final class UpdateProfileVC: BaseViewController{
    
    override func loadView() {
        view = _view
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "프로필 설정"
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: doneButton)
        setupCustomBackButton(with: UIImageView(image: Icon.close))
        
        _view.didTapProfileContainer = { [weak self] in
            guard let self else{ return }
            var config = PHPickerConfiguration(photoLibrary: .shared())
            config.filter = .any(of: [.images])
            config.selectionLimit = 1
            config.selection = .default
            let viewController = PHPickerViewController(configuration: config)
            viewController.delegate = self
            present(viewController, animated: true)
        }
        _view.didChangeGender = { [weak self] gender in
            guard let self else{ return }
            vm.updateGender(gender)
        }
        _view.didChangeBirthday = { [weak self] birthday in
            guard let self else{ return }
            vm.updateBirthday(birthday)
        }
        _view.didTapChangeNickname = { [weak self] in
            guard let self else{ return }
            let vc = UpdateNicknameVC()
            navigationController?.pushViewController(vc, animated: true)
        }
        _view.didTapLogout = { [weak self] in
            guard let self else{ return }
            vm.logout{ [weak self] in
                guard let self else{ return }
                navigateToMain()
            }
        }
        _view.didTapWithdrawal = { [weak self] in
            guard let self else{ return }
            let vc = AlertVC()
            vc.alertTitle = """
            잠깐만요!
            """
            vc.alertSubtitle = """
            탈퇴 시 계정 및 이용 기록은 모두 삭제되며,
            삭제된 데이터는 복구가 불가능해요.
            그래도 탈퇴를 진행할까요?
            """
            vc.alertNegativeTitle = "유지하기"
            vc.alertPoositiveTitle = "탈퇴하기"
            vc.didTapNegativeButton = { [weak vc] in
                vc?.dismiss(animated: true)
            }
            vc.didTapPositiveButton = { [weak vc, weak self] in
                guard let self else{ return }
                vc?.dismiss(animated: true)
                vm.withdrawal{ [weak self] in
                    guard let self else{ return }
                    navigateToMain()
                }
            }
            navigationController?.present(vc, animated: true)
        }
        
        vm.userProfilePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] userProfile in
                guard let self, let userProfile else{ return }
                doneButton.isLoading = userProfile.isLoading
                doneButton.isEnabled = userProfile.canUpdate
                
                _view.updateUser(userProfile)
                
                if userProfile.isCompleted{
                    navigationController?.popViewController(animated: true)
                }
            }.store(in: &cancellables)
        vm.load()
    }
    
    private let vm = UpdateProfileVM()
    private lazy var _view = UpdateProfileView()
    private lazy var doneButton = {
        let button = HTBarButton()
        button.setTitle("완료", for: .normal)
        button.addTarget(self, action: #selector(didTapDoneButtonAction), for: .touchUpInside)
        return button
    }()
    
    private var cancellables: [AnyCancellable] = []
    
    @objc func didTapDoneButtonAction(){
        vm.save()
    }
    
    private func navigateToMain(){
        (view.window?.windowScene?.delegate as? SceneDelegate)?.window?.rootViewController = TabBarVC()
    }
}

extension UpdateProfileVC: PHPickerViewControllerDelegate{
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        
        guard let result = results.first else{ return }
        DispatchQueue.global(qos: .userInitiated).async{ [weak self] in
            guard let asset = PHAsset.fetchAssets(withLocalIdentifiers: [result.assetIdentifier].compactMap{ $0 }, options: nil).firstObject else{ return }
            
            DispatchQueue.main.async{ [weak self] in
                guard let self else{ return }
                vm.updateProfile(reference: .photo(asset))
            }
        }
    }
}
