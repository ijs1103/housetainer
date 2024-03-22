//
//  LabelWithPadding.swift
//  Housetainer
//
//  Created by 이주상 on 2023/11/13.
//

import UIKit

final class LabelWithPadding: UILabel {
    private var topInset: CGFloat = 4.0
    private var bottomInset: CGFloat = 4.0
    private var leftInset: CGFloat = 8.0
    private var rightInset: CGFloat = 8.0
    
    init(topInset: CGFloat, bottomInset: CGFloat, leftInset: CGFloat, rightInset: CGFloat) {
        self.topInset = topInset
        self.bottomInset = bottomInset
        self.leftInset = leftInset
        self.rightInset = rightInset
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func drawText(in rect: CGRect) {
        let insets = UIEdgeInsets(top: topInset, left: leftInset, bottom: bottomInset, right: rightInset)
        super.drawText(in: rect.inset(by: insets))
    }

    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(width: size.width + leftInset + rightInset,
                      height: size.height + topInset + bottomInset)
    }

    override var bounds: CGRect {
        didSet {
            preferredMaxLayoutWidth = bounds.width - (leftInset + rightInset)
        }
    }
}
