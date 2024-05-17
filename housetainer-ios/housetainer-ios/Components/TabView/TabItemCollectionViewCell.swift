//
//  TabItemCollectionViewCell.swift
//  housetainer-ios
//
//  Created by 김수아 on 1/7/24.
//

import Foundation
import UIKit
import SnapKit

final class TabItemCollectionViewCell: UICollectionViewCell{
    
    override var isSelected: Bool{
        didSet{
            guard oldValue != isSelected else{ return }
            UIView.transition(with: titleLabel, duration: 0.3) {
                self.update(with: self.item)
                self.layoutIfNeeded()
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update(with item: Item){
        titleLabel.text = item.title
        if isSelected{
            titleLabel.font = Typo.Title1()
            titleLabel.textColor = Color.black
        }else{
            titleLabel.font = Typo.Heading2()
            titleLabel.textColor = Color.gray400
        }
        self.item = item
        setNeedsLayout()
    }
    
    // MARK: - Private
    private var item: Item = Item(title: "")
    
    // MARK: - UI Properties
    private let titleLabel = {
        let label = UILabel()
        label.font = Typo.Title1()
        label.textColor = Color.black
        return label
    }()
}

extension TabItemCollectionViewCell{
    struct Item: Equatable{
        let title: String
    }
}

private extension TabItemCollectionViewCell{
    func setupUI(){
        contentView.layoutMargins = UIEdgeInsets(top: 16, left: 12.5, bottom: 16, right: 12.5)
        contentView.addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints{
            $0.directionalEdges.equalTo(contentView.snp.directionalMargins)
        }
    }
}
