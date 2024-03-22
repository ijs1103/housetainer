//
//  CategoryView.swift
//  housetainer-ios
//
//  Created by 김수아 on 1/14/24.
//

import Foundation
import UIKit
import SwiftUI
import SnapKit

final class CategoryView: UIControl{
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
        label.font = Typo.Body2()
        label.numberOfLines = 0
        return label
    }()
    private let descriptionLabel = {
        let label = UILabel()
        label.font = Typo.Body5()
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

private extension CategoryView{
    func setupUI(){
        layoutMargins = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
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
            $0.top.equalTo(titleLabel.snp.bottom).offset(2)
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

private extension CategoryView{
    enum Theme{
        case selected
        case normal
        
        var backgroundColor: UIColor{
            switch self{
            case .selected:
                return Color.purple100
            case .normal:
                return Color.white
            }
        }
        
        var titleColor: UIColor{
            switch self{
            case .selected:
                return Color.purple500
            case .normal:
                return Color.gray700
            }
        }
        
        var descriptionColor: UIColor{
            switch self{
            case .selected:
                return Color.purple300
            case .normal:
                return Color.gray400
            }
        }
        
        var borderColor: UIColor{
            switch self{
            case .selected:
                return Color.purple200
            case .normal:
                return Color.gray300
            }
        }
        
        var borderWidth: CGFloat{
            1
        }
        
        var cornerRadius: CGFloat{
            4
        }
    }
}

struct CategoryView_Previews: PreviewProvider{
    static var previews: some View{
        ViewPreview{
            CategoryView()
        }
    }
}
