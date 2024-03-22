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
        define()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update(with item: Item){
        counterLabel.text = "\(item.numberOfPhotos)/\(item.maximum)"
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        for layer in container.layer.sublayers ?? []{
            if let layer = layer as? CAShapeLayer{
                layer.path = UIBezierPath(
                    roundedRect: container.layer.bounds.insetBy(dx: layer.lineWidth, dy: layer.lineWidth),
                    cornerRadius: 8
                ).cgPath
                layer.frame = container.layer.bounds
            }
        }
    }
    
    // MARK: - UI Properties
    private let container = UIView()
    private let vStack = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 4
        return stack
    }()
    private let imageView = {
        let imageView = UIImageView()
        imageView.image = Icon.cameraLarge
        return imageView
    }()
    private let counterLabel = {
        let label = UILabel()
        label.font = Typo.Body4()
        label.textColor = Color.gray400
        return label
    }()
}

private extension PhotoListAddItemCollectionViewCell{
    func setupUI(){
        contentView.layoutMargins = UIEdgeInsets(top: 5, left: 0, bottom: 0, right: 8)
        container.layer.addSublayer({
            let layer = CAShapeLayer()
            layer.lineWidth = 1
            layer.lineDashPattern = [2, 2]
            layer.fillColor = UIColor.clear.cgColor
            layer.strokeColor = Color.gray200.cgColor
            return layer
        }())
        contentView.addSubview(container)
        container.addSubview(vStack)
        vStack.addArrangedSubview(imageView)
        vStack.addArrangedSubview(counterLabel)
    }
    
    func define(){
        container.snp.makeConstraints{
            $0.directionalEdges.equalTo(contentView.snp.directionalMargins)
        }
        
        vStack.snp.makeConstraints{
            $0.centerY.equalToSuperview()
            $0.leading.trailing.equalToSuperview()
        }
        
        imageView.snp.makeConstraints{
            $0.width.height.equalTo(28)
        }
    }
}

extension PhotoListAddItemCollectionViewCell{
    struct Item{
        let numberOfPhotos: Int
        let maximum: Int
    }
}
