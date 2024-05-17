//
//  UIImage+.swift
//  housetainer-ios
//
//  Created by 이주상 on 4/5/24.
//

import UIKit

extension UIImage {
    var grayscaled: UIImage? {
        let ciImage = CIImage(image: self)
        let grayscale = ciImage?.applyingFilter("CIColorControls",
                                                parameters: [ kCIInputSaturationKey: 0.0 ])
        if let grayscale {
            return UIImage(ciImage: grayscale)
        } else {
            return nil
        }
    }
}
