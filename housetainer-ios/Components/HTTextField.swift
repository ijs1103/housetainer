//
//  HTTextField.swift
//  housetainer-ios
//
//  Created by 김수아 on 2/17/24.
//

import Foundation
import UIKit

final class HTTextField: UITextField{
    var leftViewInset: UIEdgeInsets = .zero{
        didSet{
            setNeedsLayout()
        }
    }
    var rightViewInset: UIEdgeInsets = .zero{
        didSet{
            setNeedsLayout()
        }
    }
    var isSelectionEnabled: Bool = true
    
    override func leftViewRect(forBounds bounds: CGRect) -> CGRect {
        super.leftViewRect(forBounds: bounds).inset(by: leftViewInset)
    }
    
    override func rightViewRect(forBounds bounds: CGRect) -> CGRect {
        super.rightViewRect(forBounds: bounds).inset(by: rightViewInset)
    }
    
    override func caretRect(for position: UITextPosition) -> CGRect {
        if isSelectionEnabled{
            return super.caretRect(for: position)
        }
        
        return .zero
    }
    
    override func selectionRects(for range: UITextRange) -> [UITextSelectionRect] {
        if isSelectionEnabled{
            return super.selectionRects(for: range)
        }
        
        return []
    }
    
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if isSelectionEnabled{
            return super.canPerformAction(action, withSender: sender)
        }
        return false
    }
}
