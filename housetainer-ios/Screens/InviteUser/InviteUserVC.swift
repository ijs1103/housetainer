//
//  InviteUserVC.swift
//  housetainer-ios
//
//  Created by 김수아 on 2/12/24.
//

import Foundation
import UIKit
import Combine

final class InviteUserVC: UIViewController{
    
    override func loadView() {
        view = _view
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCustomBackButton()
        
        _view.didChangeName = { [weak self] name in
            guard let self else{ return }
            vm.updateName(name)
        }
        _view.didChangeEmail = { [weak self] email in
            guard let self else{ return }
            vm.updateEmail(email)
        }
        _view.didTapDone = { [weak self] in
            guard let self else{ return }
            vm.requestInvite()
        }
        
        vm.inviteUserPublisher
            .receive(on: DispatchQueue.main)
            .sink{ [weak self] inviteUser in
                guard let self else{ return }
                _view.updateInviteUser(inviteUser)
                
                if inviteUser.isCompleted{
                    let vc = InviteUserCompleteVC()
                    vc.modalPresentationStyle = .fullScreen
                    navigationController?.present(vc, animated: true){ [weak self] in
                        guard let self else{ return }
                        navigationController?.popToRootViewController(animated: true)
                    }
                }
            }.store(in: &cancellables)
    }
    
    private let vm = InviteUserVM()
    private lazy var _view = InviteUserView()
    private var cancellables: [AnyCancellable] = []
}
