//
//  Data+.swift
//  housetainer-ios
//
//  Created by 이주상 on 4/26/24.
//

import Foundation
import UIKit

extension Data {
    func resizedImage(maxWidthHeight: CGFloat = 1280, compressionQuality: CGFloat = 0.8) -> Data? {
        guard let image = UIImage(data: self) else { return nil }
        
        let aspectRatio = image.size.width / image.size.height
        
        var newWidth: CGFloat
        var newHeight: CGFloat
        if aspectRatio > 1 { // 가로가 더 긴 경우
            newWidth = Swift.min(image.size.width, maxWidthHeight)
            newHeight = newWidth / aspectRatio
        } else { // 세로가 더 긴 경우
            newHeight = Swift.min(image.size.height, maxWidthHeight)
            newWidth = newHeight * aspectRatio
        }
        
        UIGraphicsBeginImageContextWithOptions(CGSize(width: newWidth, height: newHeight), false, 1.0)
        image.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return resizedImage?.jpegData(compressionQuality: compressionQuality)
    }
}
