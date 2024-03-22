//
//  UIButton+Extension.swift
//  housetainer-ios
//
//  Created by 김수아 on 2/12/24.
//

import Foundation
import UIKit

extension UIButton{
    func setBackgroundColor(_ color: UIColor?, for state: UIControl.State){
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        let renderer = UIGraphicsImageRenderer(size: rect.size)
        setBackgroundImage(renderer.image { context in
            color?.setFill()
            context.fill(rect)
        }, for: state)
    }
}
