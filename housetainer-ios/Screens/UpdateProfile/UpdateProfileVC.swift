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

final class UpdateProfileVC: UIViewController{
    
    override func loadView() {
        view = _view
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCustomBackButton()
        
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
        _view.didTapDone = { [weak self] in
            guard let self else{ return }
            vm.save()
        }
        
        vm.userProfilePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] userProfile in
                guard let self, let userProfile else{ return }
                _view.updateUser(userProfile)
            }.store(in: &cancellables)
        vm.load()
    }
    
    private let vm = UpdateProfileVM()
    private lazy var _view = UpdateProfileView()
    
    private var cancellables: [AnyCancellable] = []
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
