//
//  SpacingFactory.swift
//  Housetainer
//
//  Created by 이주상 on 2023/11/09.
//

import UIKit
 
struct SpacingFactory {
    static func build(height: CGFloat) -> UIView {
        let view = UIView()
        view.heightAnchor.constraint(equalToConstant: height).isActive = true
        return view
    }
}

