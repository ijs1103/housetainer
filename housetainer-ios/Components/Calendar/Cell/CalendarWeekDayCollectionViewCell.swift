//
//  CalendarWeekDayCollectionViewCell.swift
//  housetainer-ios
//
//  Created by 김수아 on 1/10/24.
//

import Foundation
import UIKit

final class CalendarWeekDayCollectionViewCell: UICollectionViewCell{
    override var isSelected: Bool{
        didSet{
            guard oldValue != isSelected else{ return }
            if let item{
                update(with: item)
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
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.layer.cornerRadius = contentView.frame.height / 2
    }
    
    func update(with item: Item){
        titleLabel.text = item.title
        self.item = item
    }
    
    // MARK: - Private
    private var item: Item?
    
    // MARK: - UI Properties
    private let titleLabel = {
        let label = UILabel()
        label.font = Typo.Body3()
        label.textColor = Color.gray500
        label.textAlignment = .center
        label.lineBreakMode = .byClipping
        return label
    }()
}

private extension CalendarWeekDayCollectionViewCell{
    func setupUI(){
        contentView.layoutMargins = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        contentView.layer.masksToBounds = true
        contentView.addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints{
            $0.directionalEdges.equalTo(contentView.snp.directionalMargins)
        }
    }
}

extension CalendarWeekDayCollectionViewCell{
    struct Item: Equatable{
        let title: String
    }
}
