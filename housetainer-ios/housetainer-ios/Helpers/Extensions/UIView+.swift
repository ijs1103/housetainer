//
//  UIView+.swift
//  Housetainer
//
//  Created by 이주상 on 2023/11/10.
//

import UIKit

enum BorderSide: CaseIterable {
    case top, bottom, left, right
}

extension UIView {
    func addBorder(side: BorderSide, color: UIColor, width: CGFloat) {
        let border = UIView()
        border.translatesAutoresizingMaskIntoConstraints = false
        border.backgroundColor = color
        self.addSubview(border)
        
        let topConstraint = topAnchor.constraint(equalTo: border.topAnchor)
        let rightConstraint = trailingAnchor.constraint(equalTo: border.trailingAnchor)
        let bottomConstraint = bottomAnchor.constraint(equalTo: border.bottomAnchor)
        let leftConstraint = leadingAnchor.constraint(equalTo: border.leadingAnchor)
        let heightConstraint = border.heightAnchor.constraint(equalToConstant: width)
        let widthConstraint = border.widthAnchor.constraint(equalToConstant: width)
        
        switch side {
        case .top:
            NSLayoutConstraint.activate([leftConstraint, topConstraint, rightConstraint, heightConstraint])
        case .right:
            NSLayoutConstraint.activate([topConstraint, rightConstraint, bottomConstraint, widthConstraint])
        case .bottom:
            NSLayoutConstraint.activate([rightConstraint, bottomConstraint, leftConstraint, heightConstraint])
        case .left:
            NSLayoutConstraint.activate([bottomConstraint, leftConstraint, topConstraint, widthConstraint])
        }
    }
    
    func removeBorder() {
        for sub in self.subviews{
            sub.removeFromSuperview()
        }
    }
    
    func removeRedBorder() {
        for sub in self.subviews{
            if sub.backgroundColor == Color.red200 {
                sub.removeFromSuperview()
            }
        }
    }
    
    func removePurpleBorder() {
        for sub in self.subviews{
            if sub.backgroundColor == Color.purple300 {
                sub.removeFromSuperview()
            }
        }
    }
}
