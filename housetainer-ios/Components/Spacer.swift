//
//  Spacer.swift
//  Housetainer
//
//  Created by 이주상 on 2023/11/26.
//

import UIKit

final class Spacer: UIView {
    
    init(height: CGFloat) {
        super.init(frame: .zero)
        heightAnchor.constraint(equalToConstant: height).isActive = true
        backgroundColor = Color.gray100
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
