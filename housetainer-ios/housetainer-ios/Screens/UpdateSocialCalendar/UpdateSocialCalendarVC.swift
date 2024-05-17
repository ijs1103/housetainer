//
//  UpdateSocialCalendarVC.swift
//  housetainer-ios
//
//  Created by 이주상 on 2/18/24.
//

import Foundation
import UIKit
import PhotosUI
import Combine

final class UpdateSocialCalendarVC: BaseViewController {
    
    init(event: EventDetailResponse) {
        self.vm = UpdateSocialCalendarVM(event: event)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = _view
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "일정 수정"
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: doneButton)
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
                    navigationController?.popViewController(animated: true)
                }
            }.store(in: &cancellables)
        
        vm.toastPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] toastMessage in
                guard let self else{ return }
                
                view.makeToast(toastMessage, duration: 3.0, position: .center)
            }.store(in: &cancellables)
        
        vm.isEventUpdated
            .receive(on: RunLoop.main)
            .sink { [weak self] isEventUpdated in
                guard let self, let isEventUpdated else { return }
                if isEventUpdated {
                    view.makeToast(ToastMessage.eventUpdatingSuccess, duration: 2.0, position: .center) { _ in
                        self.navigationController?.popViewController(animated: true)
                    }
                } else {
                    view.makeToast(ToastMessage.eventUpdatingFailed, duration: 2.0, position: .center)
                }
            }.store(in: &cancellables)
    }
    
    private let _view = CreateSocialCalendarView()
    private lazy var doneButton = {
        let button = HTBarButton()
        button.setTitle("추가", for: .normal)
        button.addTarget(self, action: #selector(didTapDoneButtonAction), for: .touchUpInside)
        return button
    }()
    private let vm: UpdateSocialCalendarVM
    private var cancellables: [AnyCancellable] = []
    
    @objc func didTapDoneButtonAction(){
        vm.save()
    }
}

extension UpdateSocialCalendarVC: SelectDateVCDelegate{
    func selectDateVc(didSelect date: Date?) {
        vm.updateDate(date)
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
                vm.updateImageRefs([.photo(asset)])
            }
        }
    }
}
