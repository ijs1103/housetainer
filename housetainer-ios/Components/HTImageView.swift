//
//  HTImageView.swift
//  housetainer-ios
//
//  Created by 김수아 on 1/9/24.
//

import Foundation
import UIKit

final class HTImageView: UIImageView{
    var didLayout: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        didLayout?()
    }
}
