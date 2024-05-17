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
        view.layer.cornerRadius = 12
        view.layer.masksToBounds = true
        return view
    }()
    private let imageView = {
        let imageView = UIImageView()
        return imageView
    }()
    private let mainLabel = {
        let label = LabelWithPadding(topInset: 8, bottomInset: 8, leftInset: 12, rightInset: 12)
        label.textAlignment = .center
        label.backgroundColor = Color.reddishPurple400
        label.textColor = Color.gray100
        label.font = Typo.Body3Medium()
        label.text = "대표"
        label.layer.cornerRadius = 4
        label.layer.masksToBounds = true
        return label
    }()
    private lazy var deleteImageView = {
        let imageView = InternalImageView()
        imageView.image = Icon.imageClear
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapDeleteAction)))
        return imageView
    }()
}

private extension PhotoListItemCollectionViewCell{
    func setupUI(){
        contentView.layoutMargins = .init(top: 12, left: 0, bottom: 0, right: 12 + 12)
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
            $0.leading.top.equalToSuperview().inset(12)
            $0.bottom.trailing.lessThanOrEqualToSuperview().inset(12)
        }
        
        deleteImageView.snp.makeConstraints{
            $0.top.equalToSuperview()
            $0.trailing.equalToSuperview().inset(12)
            $0.size.equalTo(32)
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

private final class InternalImageView: UIImageView{
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let newBound = CGRect(
            x: self.bounds.origin.x,
            y: self.bounds.origin.y - 12,
            width: self.bounds.width + 12,
            height: self.bounds.height + 12
        )
        return newBound.contains(point)
    }
}
