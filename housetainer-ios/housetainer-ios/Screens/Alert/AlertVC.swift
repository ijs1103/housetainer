//
//  AlertVC.swift
//  housetainer-ios
//
//  Created by 김수아 on 4/14/24.
//

import Foundation
import UIKit

final class AlertVC: BaseViewController{
    var alertTitle: String = ""{
        didSet{
            guard isViewLoaded else{ return }
            _view.title = alertTitle
        }
    }
    var alertSubtitle: String = ""{
        didSet{
            guard isViewLoaded else{ return }
            _view.subtitle = alertSubtitle
        }
    }
    var alertNegativeTitle: String = ""{
        didSet{
            guard isViewLoaded else{ return }
            _view.negativeTitle = alertNegativeTitle
        }
    }
    var alertPoositiveTitle: String = ""{
        didSet{
            guard isViewLoaded else{ return }
            _view.positiveTitle = alertPoositiveTitle
        }
    }
    var didTapNegativeButton: (() -> Void)?
    var didTapPositiveButton: (() -> Void)?
    
    init(){
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .overFullScreen
        modalTransitionStyle = .crossDissolve
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = _view
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        _view.title = alertTitle
        _view.subtitle = alertSubtitle
        _view.negativeTitle = alertNegativeTitle
        _view.positiveTitle = alertPoositiveTitle
        _view.didTapBackground = { [weak self] in
            guard let self else { return }
            dismiss(animated: true)
        }
        _view.didTapNegativeButton = { [weak self] in
            guard let self else{ return }
            didTapNegativeButton?()
        }
        _view.didTapPositiveButton = { [weak self] in
            guard let self else{ return }
            didTapPositiveButton?()
        }
    }
    
    private lazy var _view = AlertView()
}
