//
//  HTCollectionView.swift
//  housetainer-ios
//
//  Created by 김수아 on 1/8/24.
//

import Foundation
import UIKit

final class HTCollectionView: UICollectionView{
    var didLayout: (() -> Void)?
    
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
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
