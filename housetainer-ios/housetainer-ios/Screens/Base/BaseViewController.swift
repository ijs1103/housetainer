//
//  BaseViewController.swift
//  housetainer-ios
//
//  Created by 김수아 on 4/1/24.
//

import Foundation
import UIKit

open class BaseViewController: UIViewController{
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapRootAction))
        gestureRecognizer.cancelsTouchesInView = false
        view.addGestureRecognizer(gestureRecognizer)
    }
    
    @objc private func didTapRootAction(){
        view.endEditing(true)
    }
}
