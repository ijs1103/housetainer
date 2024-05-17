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

final class CreateSocialCalendarVC: BaseViewController{
    
    override func loadView() {
        view = _view
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "일정 생성"
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: doneButton)
        setupCustomBackButton(with: UIImageView(image: Icon.close))
        
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
        _view.didTapDelete = { [weak self] in
            guard let self else{ return }
            doneButton.isEnabled = false
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
        
        vm.createSocialCalendarPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] createSocialCalendar in
                guard let self else{ return }
                doneButton.isEnabled = createSocialCalendar.canUpdate
                doneButton.isLoading = createSocialCalendar.isLoading
                _view.updateCreateSocialCalendar(createSocialCalendar)
                
                if createSocialCalendar.isCompleted{
                    dismiss(animated: true)
                }
            }.store(in: &cancellables)
        vm.load()
        
        vm.isEventCreated
            .receive(on: RunLoop.main)
            .sink { [weak self] isEventCreated in
                guard let self, let isEventCreated else { return }
                if isEventCreated {
                    self.dismiss(animated: true) {
                        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                           let rootViewController = windowScene.windows.first?.rootViewController {
                            rootViewController.view.makeToast(ToastMessage.eventInsertingSuccess, duration: 2.0, position: .center)
                        }
                    }
                } else {
                    view.makeToast(ToastMessage.eventInsertingFailed, duration: 2.0, position: .center)
                }
            }.store(in: &cancellables)
    }
    
    @objc func didTapRightButtonAction(){
        vm.saveAsTemp()
        dismiss(animated: true)
    }
    
    private let vm = CreateSocialCalendarVM()
    private lazy var _view = CreateSocialCalendarView()
    private lazy var doneButton = {
        let button = HTBarButton()
        button.setTitle("추가", for: .normal)
        button.addTarget(self, action: #selector(didTapDoneButtonAction), for: .touchUpInside)
        return button
    }()
    private var cancellables: [AnyCancellable] = []
    
    @objc func didTapDoneButtonAction(){
        Task {
            await vm.createSocialCalendar()
        }
    }
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
