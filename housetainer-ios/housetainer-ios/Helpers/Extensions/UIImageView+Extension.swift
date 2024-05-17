//
//  UIImageView+Extension.swift
//  housetainer-ios
//
//  Created by 김수아 on 2/17/24.
//

import Foundation
import UIKit
import Photos

private var photoRequestIdKey: Void?

extension UIImageView{
    private var photoRequestId: PHImageRequestID?{
        get{
            objc_getAssociatedObject(self, &photoRequestIdKey) as? PHImageRequestID
        }
        set{
            objc_setAssociatedObject(self, &photoRequestIdKey, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
    }
    
    func setImage(_ imageRef: ImageReference?, placeholder: UIImage? = nil){
        self.image = placeholder
        
        if let photoRequestId{
            PHImageManager.default().cancelImageRequest(photoRequestId)
        }
        
        switch imageRef{
        case let .photo(asset):
            var options = PHImageRequestOptions()
            options.deliveryMode = .opportunistic
            options.resizeMode = .fast
            photoRequestId = PHImageManager.default().requestImage(for: asset, targetSize: bounds.size, contentMode: .aspectFill, options: options) { [weak self] image, info in
                guard let self else{ return }
                self.image = image
            }
        case let .image(image):
            self.image = image
        case let .url(url):
            self.kf.setImage(with: url, placeholder: placeholder)
        case .none:
            break
        }
    }
}
