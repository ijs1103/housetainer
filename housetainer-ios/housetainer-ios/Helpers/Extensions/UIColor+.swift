//
//  UIColor+.swift
//  housetainer-ios
//
//  Created by 이주상 on 1/25/24.
//

import UIKit

extension UIColor {
    // UIColor를 UIImage로 변환
    func image(_ size: CGSize = CGSize(width: 1, height: 1)) -> UIImage {
        return UIGraphicsImageRenderer(size: size).image { rendererContext in
            self.setFill()
            rendererContext.fill(CGRect(origin: .zero, size: size))
        }
    }
}

extension UIColor{
    convenience init(rgb hex: UInt64){
        let r = CGFloat((hex & 0xff0000) >> 16) / 255
        let g = CGFloat((hex & 0x00ff00) >> 8) / 255
        let b = CGFloat(hex & 0x0000ff) / 255

        self.init(red: r, green: g, blue: b, alpha: 1)
    }
    
    convenience init(rgba hex: UInt64){
        let r = CGFloat((hex & 0xff000000) >> 24) / 255
        let g = CGFloat((hex & 0x00ff0000) >> 16) / 255
        let b = CGFloat((hex & 0x0000ff00) >> 8) / 255
        let a = CGFloat(hex & 0x000000ff) / 255

        self.init(red: r, green: g, blue: b, alpha: a)
    }
}
