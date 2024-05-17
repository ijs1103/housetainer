//
//  PhotoListAddItemCollectionViewCell.swift
//  housetainer-ios
//
//  Created by 김수아 on 1/14/24.
//

import Foundation
import UIKit
import SwiftUI
import SnapKit

final class PhotoListAddItemCollectionViewCell: UICollectionViewCell{
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func updateConstraints() {
        container.snp.updateConstraints{
            $0.top.equalToSuperview().inset(12)
            $0.trailing.equalToSuperview().inset(12)
            $0.leading.bottom.equalToSuperview()
        }
        
        imageView.snp.updateConstraints{
            $0.center.equalToSuperview()
            $0.size.equalTo(24)
        }
        
        super.updateConstraints()
    }
    
    // MARK: - UI Properties
    private let container = {
        let view = UIView()
        view.layer.cornerRadius = 12
        view.layer.borderWidth = 1
        view.layer.borderColor = Color.gray150.cgColor
        view.layer.masksToBounds = true
        return view
    }()
    
    private let imageView = {
        let imageView = UIImageView()
        imageView.image = Icon.addAPhoto
        return imageView
    }()
}

private extension PhotoListAddItemCollectionViewCell{
    func setupUI(){
        contentView.addSubview(container)
        container.addSubview(imageView)
        
        setNeedsUpdateConstraints()
    }
}
