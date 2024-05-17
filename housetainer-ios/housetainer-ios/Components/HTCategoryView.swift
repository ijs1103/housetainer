//
//  HTCategoryView.swift
//  housetainer-ios
//
//  Created by 김수아 on 4/16/24.
//

import Foundation
import UIKit
import SwiftUI
import SnapKit

final class HTCategoryView: UIControl{
    var title: String = ""{
        didSet{
            titleLabel.text = title
            refresh()
        }
    }
    var desc: String = ""{
        didSet{
            descriptionLabel.text = desc
            refresh()
        }
    }
    override var isSelected: Bool{
        didSet{
            theme = isSelected ? .selected : .normal
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        define()
        refreshTheme()
        refresh()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI Properties
    private let titleLabel = {
        let label = UILabel()
        label.font = Typo.Body1Medium()
        label.textColor = Color.gray800
        label.numberOfLines = 0
        return label
    }()
    private let descriptionLabel = {
        let label = UILabel()
        label.font = Typo.Body3()
        label.textColor = Color.gray500
        label.numberOfLines = 0
        return label
    }()
    
    // MARK: - Private
    private var theme: Theme = .normal{
        didSet{
            guard oldValue != theme else{ return }
            refreshTheme()
        }
    }
}

private extension HTCategoryView{
    func setupUI(){
        layoutMargins = UIEdgeInsets(top: 24, left: 24, bottom: 24, right: 24)
        addSubview(titleLabel)
        addSubview(descriptionLabel)
    }
    
    func define(){
        titleLabel.snp.makeConstraints{
            $0.top.equalTo(self.snp.topMargin)
            $0.leading.greaterThanOrEqualTo(self.snp.leadingMargin)
            $0.trailing.lessThanOrEqualTo(self.snp.trailingMargin)
            $0.centerX.equalToSuperview()
        }
        descriptionLabel.snp.makeConstraints{
            $0.top.equalTo(titleLabel.snp.bottom).offset(4)
            $0.leading.greaterThanOrEqualTo(self.snp.leadingMargin)
            $0.trailing.lessThanOrEqualTo(self.snp.trailingMargin)
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(self.snp.bottomMargin)
        }
    }
    
    func refreshTheme(){
        backgroundColor = theme.backgroundColor
        titleLabel.textColor = theme.titleColor
        descriptionLabel.textColor = theme.descriptionColor
        layer.borderWidth = theme.borderWidth
        layer.borderColor = theme.borderColor.cgColor
        layer.cornerRadius = theme.cornerRadius
    }
    
    func refresh(){
        descriptionLabel.snp.updateConstraints{
            $0.top.equalTo(titleLabel.snp.bottom).offset(title.isEmpty || description.isEmpty ? 0 : 2)
        }
    }
}

private extension HTCategoryView{
    enum Theme{
        case selected
        case normal
        
        var backgroundColor: UIColor{
            switch self{
            case .selected:
                return UIColor(rgb: 0xF8D8F0)
            case .normal:
                return Color.white
            }
        }
        
        var titleColor: UIColor{
            switch self{
            case .selected:
                return Color.reddishPurple600
            case .normal:
                return Color.gray800
            }
        }
        
        var descriptionColor: UIColor{
            switch self{
            case .selected:
                return Color.reddishPurple400
            case .normal:
                return Color.gray500
            }
        }
        
        var borderColor: UIColor{
            switch self{
            case .selected:
                return Color.reddishPurple100
            case .normal:
                return Color.gray150
            }
        }
        
        var borderWidth: CGFloat{
            1
        }
        
        var cornerRadius: CGFloat{
            12
        }
    }
}

struct HTCategoryView_Previews: PreviewProvider{
    static var previews: some View{
        ViewPreview{
            HTCategoryView()
        }
    }
}

