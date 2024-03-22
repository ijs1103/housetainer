//
//  CalendarDayCollectionViewCell.swift
//  housetainer-ios
//
//  Created by 김수아 on 1/10/24.
//

import Foundation
import UIKit

final class CalendarDayCollectionViewCell: UICollectionViewCell{
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
        if let day = item.day{
            titleLabel.text = "\(day.day)"
        }else{
            titleLabel.text = ""
        }
        if !item.isEnabled{
            contentView.backgroundColor = .clear
            titleLabel.textColor = Color.gray300
        }else if isSelected{
            contentView.backgroundColor = Color.purple300
            titleLabel.textColor = Color.white
        }else{
            contentView.backgroundColor = .clear
            titleLabel.textColor = Color.black
        }
        isUserInteractionEnabled = item.day != nil && item.isEnabled
        self.item = item
    }
    
    // MARK: - Private
    private var item: Item?
    
    // MARK: - UI Properties
    private let titleLabel = {
        let label = UILabel()
        label.font = Typo.Body3()
        label.textColor = Color.black
        label.textAlignment = .center
        return label
    }()
}

private extension CalendarDayCollectionViewCell{
    func setupUI(){
        contentView.layoutMargins = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        contentView.layer.masksToBounds = true
        contentView.addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints{
            $0.directionalEdges.equalTo(contentView.snp.directionalMargins)
        }
    }
}

extension CalendarDayCollectionViewCell{
    struct Item: Equatable{
        let day: DayOfMonth?
        let isEnabled: Bool
    }
}
