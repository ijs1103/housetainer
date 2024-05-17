//
//  UIFont+Extension.swift
//  housetainer-ios
//
//  Created by 김수아 on 4/8/24.
//

import Foundation
import UIKit

extension UIFont{
    enum PlayfairDisplay{
        case regular
        
        fileprivate var name: String{
            "Playfair Display"
        }
    }
    
    static func name(_ name: PlayfairDisplay, size: CGFloat) -> UIFont{
        UIFont(name: name.name, size: size)!
    }
}
