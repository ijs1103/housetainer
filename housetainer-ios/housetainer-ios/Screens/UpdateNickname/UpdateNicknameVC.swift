//
//  UpdateNicknameVC.swift
//  housetainer-ios
//
//  Created by 김수아 on 1/16/24.
//

import Foundation
import UIKit
import Combine

final class UpdateNicknameVC: BaseViewController{
    
    override func loadView() {
        view = _view
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCustomBackButton()
        
        _view.didChangeNickname = { [weak self] nickname in
            guard let self else{ return }
            vm.updateNickname(nickname)
        }
        _view.didTapDone = { [weak self] in
            guard let self else{ return }
            vm.saveNickname()
        }
        
        vm.errorPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] error in
                guard let self else{ return }
                _view.updateError(error)
            }.store(in: &cancellables)
        vm.userNicknamePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] userNickname in
                guard let self, let userNickname else{ return }
                _view.updateNickname(userNickname)
                
                if userNickname.isCompleted{
                    navigationController?.popViewController(animated: true)
                }
            }.store(in: &cancellables)
        vm.load()
    }
    
    private let vm = UpdateNicknameVM()
    private lazy var _view = UpdateNicknameView()
    private var cancellables: [AnyCancellable] = []
}
