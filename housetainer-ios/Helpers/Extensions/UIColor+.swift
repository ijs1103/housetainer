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
