//
//  HTView.swift
//  housetainer-ios
//
//  Created by 김수아 on 4/13/24.
//

import Foundation
import UIKit

final class HTView: UIView{
    var didLayout: (() -> Void)?
    
    override func layoutSubviews() {
        super.layoutSubviews()
        didLayout?()
    }
}
