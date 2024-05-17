//
//  SheetItemCollectionViewCell.swift
//  housetainer-ios
//
//  Created by 김수아 on 3/24/24.
//

import Foundation
import UIKit

final class SheetItemCollectionViewCell: UICollectionViewCell{
    struct Item{
        let title: String
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with item: Item){
        titleLabel.text = item.title
    }
    
    // MARK: - Private
    private let titleLabel = {
        let label = UILabel()
        label.font = Typo.Body1()
        label.textColor = Color.black
        label.textAlignment = .center
        return label
    }()
}

private extension SheetItemCollectionViewCell{
    func setupUI(){
        contentView.addSubview(titleLabel)
        contentView.layoutMargins = .init(top: 10, left: 10, bottom: 10, right: 10)
        
        titleLabel.snp.makeConstraints{
            $0.edges.equalTo(contentView.layoutMarginsGuide.snp.edges)
        }
    }
}
