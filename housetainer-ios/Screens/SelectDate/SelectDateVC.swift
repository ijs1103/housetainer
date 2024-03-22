//
//  SelectDateVC.swift
//  housetainer-ios
//
//  Created by 김수아 on 2/17/24.
//

import Foundation
import UIKit

protocol SelectDateVCDelegate: AnyObject{
    func selectDateVc(didSelect date: Date?)
}

final class SelectDateVC: UIViewController{
    
    weak var delegate: SelectDateVCDelegate?
    
    init(){
        super.init(nibName: nil, bundle: nil)
        modalTransitionStyle = .crossDissolve
        modalPresentationStyle = .overFullScreen
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = _view
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        _view.didTapClose = { [weak self] selectedDate in
            guard let self else{ return }
            delegate?.selectDateVc(didSelect: selectedDate)
            dismiss(animated: true)
        }
        _view.didTapDim = { [weak self] in
            guard let self else{ return }
            dismiss(animated: true)
        }
    }
    
    private lazy var _view = SelectDateView()
}
