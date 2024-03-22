//
//  PhotoListItemCollectionViewcell.swift
//  housetainer-ios
//
//  Created by 김수아 on 1/14/24.
//

import Foundation
import UIKit
import SwiftUI
import SnapKit

final class PhotoListItemCollectionViewCell: UICollectionViewCell{
    var didTapDelete: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        define()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update(with item: Item){
        imageView.setImage(item.reference)
        mainLabel.isHidden = !item.isMain
    }
    
    // MARK: - UI Properties
    private let container = {
        let view = UIView()
        view.layer.cornerRadius = 8
        view.layer.masksToBounds = true
        return view
    }()
    private let imageView = {
        let imageView = UIImageView()
        return imageView
    }()
    private let mainLabel = {
        let label = LabelWithPadding(topInset: 6, bottomInset: 6, leftInset: 6, rightInset: 6)
        label.textAlignment = .center
        label.backgroundColor = Color.black
        label.textColor = Color.white
        label.font = Typo.Body5()
        label.text = "대표사진"
        return label
    }()
    private lazy var deleteImageView = {
        let imageView = UIImageView()
        imageView.image = Icon.imageClear
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapDeleteAction)))
        return imageView
    }()
}

private extension PhotoListItemCollectionViewCell{
    func setupUI(){
        contentView.layoutMargins = UIEdgeInsets(top: 5, left: 0, bottom: 0, right: 8)
        contentView.addSubview(container)
        container.addSubview(imageView)
        container.addSubview(mainLabel)
        contentView.addSubview(deleteImageView)
    }
    
    func define(){
        container.snp.makeConstraints{
            $0.directionalEdges.equalTo(contentView.snp.directionalMargins)
        }
        
        imageView.snp.makeConstraints{
            $0.directionalEdges.equalToSuperview()
        }
        
        mainLabel.snp.makeConstraints{
            $0.directionalHorizontalEdges.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
        
        deleteImageView.snp.makeConstraints{
            $0.top.trailing.equalToSuperview()
        }
    }
    
    @objc func didTapDeleteAction(){
        didTapDelete?()
    }
}

extension PhotoListItemCollectionViewCell{
    struct Item{
        let reference: ImageReference
        let isMain: Bool
        let canDelete: Bool = true
    }
}
