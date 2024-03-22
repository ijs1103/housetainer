//
//  NSAttributedString+Extension.swift
//  housetainer-ios
//
//  Created by 김수아 on 2/28/24.
//

import Foundation
import UIKit

@resultBuilder
struct NSAttributedStringBuilder{
    static func buildBlock(_ components: NSAttributedString...) -> NSAttributedString {
        NSMutableAttributedString(attributedStrings: components)
    }
    
    static func buildEither(first component: NSAttributedString) -> NSAttributedString {
        component
    }
    
    static func buildEither(second component: NSAttributedString) -> NSAttributedString {
        component
    }
    
    static func buildOptional(_ component: NSAttributedString?) -> NSAttributedString {
        component ?? NSAttributedString()
    }
    
    static func buildArray(_ components: [NSAttributedString]) -> NSAttributedString {
        NSMutableAttributedString(attributedStrings: components)
    }
    
    static func buildFinalResult(_ component: NSAttributedString) -> NSAttributedString {
        component
    }
}

extension NSAttributedString{
    convenience init(@NSAttributedStringBuilder builder: () -> NSAttributedString){
        self.init(attributedString: builder())
    }
    
    static func spacing(width: CGFloat) -> NSAttributedString{
        Self(attachment: {
            let spaceAttachment = NSTextAttachment()
            spaceAttachment.bounds = CGRect(origin: .zero, size: CGSize(width: 4, height: 0))
            return spaceAttachment
        }())
    }
    
    static func image(_ image: UIImage) -> NSAttributedString{
        Self(attachment: NSTextAttachment(image: image))
    }
}

private extension NSMutableAttributedString{
    
    convenience init(attributedStrings: [NSAttributedString]){
        self.init()
        attributedStrings.forEach{
            self.append($0)
        }
    }
}
