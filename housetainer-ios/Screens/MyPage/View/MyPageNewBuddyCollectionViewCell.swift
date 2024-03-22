//
//  MyPageNewBuddyCollectionViewCell.swift
//  housetainer-ios
//
//  Created by 김수아 on 1/2/24.
//

import Foundation
import UIKit
import SwiftUI
import SnapKit

final class MyPageNewBuddyCollectionViewCell: UICollectionViewCell{
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        for layer in contentView.layer.sublayers ?? []{
            if let layer = layer as? CAShapeLayer{
                layer.path = UIBezierPath(
                    roundedRect: contentView.layer.bounds.insetBy(dx: layer.lineWidth, dy: layer.lineWidth),
                    cornerRadius: 8
                ).cgPath
                layer.frame = contentView.layer.bounds
            }
        }
    }
    
    // MARK: - UI Properties
    private let newImageView = {
        let imageView = UIImageView()
        imageView.image = Icon.add
        return imageView
    }()
}

private extension MyPageNewBuddyCollectionViewCell{
    func setupUI(){
        contentView.layer.addSublayer({
            let layer = CAShapeLayer()
            layer.lineWidth = 1
            layer.lineDashPattern = [2, 2]
            layer.fillColor = Color.white.cgColor
            layer.strokeColor = Color.gray200.cgColor
            return layer
        }())
        contentView.addSubview(newImageView)
        
        contentView.snp.makeConstraints{
            $0.edges.equalToSuperview()
            $0.width.equalTo(103)
        }
    
        newImageView.snp.makeConstraints{
            $0.center.equalToSuperview()
            $0.size.equalTo(24)
        }
    }
}

struct MyPageNewBuddyCollectionViewCell_Previews: PreviewProvider{
    static var previews: some View{
        ViewPreview{
            MyPageNewBuddyCollectionViewCell()
        }
    }
}
