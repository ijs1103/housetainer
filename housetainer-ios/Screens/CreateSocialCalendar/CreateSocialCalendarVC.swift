//
//  CreateSocialCalendarVC.swift
//  housetainer-ios
//
//  Created by 김수아 on 1/14/24.
//

import Foundation
import UIKit
import PhotosUI
import Combine

final class CreateSocialCalendarVC: UIViewController{
    
    override func loadView() {
        view = _view
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCustomBackButton()
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: {
            let button = UIButton()
            button.titleLabel?.font = Typo.Body3()
            button.setTitle("임시저장", for: .normal)
            button.setTitleColor(Color.gray600, for: .normal)
            button.addTarget(self, action: #selector(didTapRightButtonAction), for: .touchUpInside)
            return button
        }())
        
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
        _view.didChangeTitle = { [weak self] title in
            guard let self else{ return }
            vm.updateTitle(title)
        }
        _view.didChangeLink = { [weak self] link in
            guard let self else{ return }
            vm.updateLink(link)
        }
        _view.didChangeDescription = { [weak self] description in
            guard let self else{ return }
            vm.updateDescription(description)
        }
        _view.didTapScheduleType = { [weak self] scheduleType in
            guard let self else{ return }
            vm.updateScheduleType(scheduleType)
        }
        _view.didTapDone = { [weak self] _ in
            guard let self else{ return }
            vm.save()
        }
        
        vm.createSocialCalendarPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] createSocialCalendar in
                guard let self else{ return }
                _view.updateCreateSocialCalendar(createSocialCalendar)
                
                if createSocialCalendar.isCompleted{
                    dismiss(animated: true)
                }
            }.store(in: &cancellables)
        vm.load()
    }
    
    @objc func didTapRightButtonAction(){
        vm.saveAsTemp()
        dismiss(animated: true)
    }
    
    private let vm = CreateSocialCalendarVM()
    private lazy var _view = CreateSocialCalendarView()
    private var cancellables: [AnyCancellable] = []
}

extension CreateSocialCalendarVC: SelectDateVCDelegate{
    func selectDateVc(didSelect date: Date?) {
        vm.updateDate(date)
    }
}

extension CreateSocialCalendarVC: PHPickerViewControllerDelegate{
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        
        guard let result = results.first else{ return }
        DispatchQueue.global(qos: .userInitiated).async{ [weak self] in
            guard let asset = PHAsset.fetchAssets(withLocalIdentifiers: [result.assetIdentifier].compactMap{ $0 }, options: nil).firstObject else{ return }
            
            DispatchQueue.main.async{ [weak self] in
                guard let self else{ return }
                vm.updateImageRefs([.photo(asset)])
            }
        }
    }
}
