//
//  CreateHouseInfoVC.swift
//  housetainer-ios
//
//  Created by 김수아 on 2/13/24.
//

import Foundation
import UIKit

final class CreateHouseInfoVC: UIViewController{
    
    override func loadView() {
        view = _view
    }
    
    private lazy var _view = CreateHouseInfoView()
}
