//
//  UpdateSocialCalendarVC.swift
//  housetainer-ios
//
//  Created by 이주상 on 2/18/24.
//

import Foundation
import UIKit
import PhotosUI

final class UpdateSocialCalendarVC: UIViewController {
    
    private let viewModel = UpdateSocialCalendarVM()
    
    init(event: EventDetailResponse) {
        self._view = CreateSocialCalendarView(eventId: event.id)
        super.init(nibName: nil, bundle: nil)
        _view.configure(with: event)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = _view
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCustomBackButton()
        _view.didTapDate = { [weak self] in
            guard let self else{ return }
            let viewController = SelectDateVC()
            viewController.delegate = self
            present(viewController, animated: true)
        }
        _view.didTapNew = { [weak self] in
            guard let self else{ return }
            var config = PHPickerConfiguration(photoLibrary: .shared())
            config.filter = .any(of: [.images])
            config.selectionLimit = 1
            config.selection = .default
            let viewController = PHPickerViewController(configuration: config)
            viewController.delegate = self
            present(viewController, animated: true)
        }
        _view.didTapDone = { [weak self] event in
            guard let self, let event else { return }
            Task {
                let isUpdatingSuccess = await self.viewModel.updateEvent(event)
                if isUpdatingSuccess {
                    self.view.makeToast("소셜캘린더가 수정되었습니다", duration: 3.0, position: .center) { _ in
                        self.navigationController?.popViewController(animated: true)
                    }
                } else {
                    self.view.makeToast("소셜캘린더 수정에 실패하였습니다", duration: 3.0, position: .center)
                }                
            }
        }
    }
    
    private let _view: CreateSocialCalendarView
}

extension UpdateSocialCalendarVC: SelectDateVCDelegate{
    func selectDateVc(didSelect date: Date?) {
        // FIXME
//        _view.selectedDate = date
    }
}

extension UpdateSocialCalendarVC: PHPickerViewControllerDelegate{
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        
        guard let result = results.first else{ return }
        DispatchQueue.global(qos: .userInitiated).async{ [weak self] in
            guard let asset = PHAsset.fetchAssets(withLocalIdentifiers: [result.assetIdentifier].compactMap{ $0 }, options: nil).firstObject else{ return }
            
            DispatchQueue.main.async{ [weak self] in
                guard let self else{ return }
                // FIXME
//                _view.selectedImage = [.photo(asset)]
            }
        }
    }
}
