//
//  InviteUserCompleteVC.swift
//  housetainer-ios
//
//  Created by 김수아 on 2/12/24.
//

import Foundation
import UIKit

final class InviteUserCompleteVC: UIViewController{
    
    override func loadView() {
        view = _view
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        _view.didTapClose = { [weak self] in
            guard let self else{ return }
            dismiss(animated: true)
        }
    }
    
    private lazy var _view = InviteUserCompleteView()
}

