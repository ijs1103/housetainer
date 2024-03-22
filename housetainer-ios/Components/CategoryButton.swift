//
//  EventScheduleButton.swift
//  housetainer-ios
//
//  Created by 이주상 on 12/27/23.
//

import UIKit
import SnapKit

protocol CategoryButtonDelegate: AnyObject {
    func didTapCategoryButton(category: Category)
}

final class CategoryButton: UIView {
    
    weak var delegate: CategoryButtonDelegate?
    private let category: Category
    
    private lazy var title: UILabel = {
        let label = LabelWithPadding(topInset: 10, bottomInset: 10, leftInset: 17, rightInset: 17)
        label.text = category.rawValue
        label.font = Typo.Body5()
        label.textColor = Color.gray500
        label.backgroundColor = .white
        label.layer.cornerRadius = 17
        label.clipsToBounds = true
        label.layer.borderColor = Color.gray100.cgColor
        label.layer.borderWidth = 1
        return label
    }()
    
    init(category: Category, isSelected: Bool = false) {
        self.category = category
        super.init(frame: .zero)
        setUI()
        setGesture()
        toggleSelected(isSelected)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension CategoryButton {
    func toggleSelected(_ isSelected: Bool) {
        if isSelected {
            title.backgroundColor = Color.purple300
            title.textColor = .white
            title.layer.borderColor = UIColor.clear.cgColor
        } else {
            title.backgroundColor = .white
            title.textColor = Color.gray500
            title.layer.borderColor = Color.gray100.cgColor
        }
    }
    
    private func setUI() {
        addSubview(title)
        
        title.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    private func setGesture() {
        let tgr = UITapGestureRecognizer(target: self, action: #selector(didTapCategoryButton))
        isUserInteractionEnabled = true 
        addGestureRecognizer(tgr)
    }
    
    @objc private func didTapCategoryButton() {
        delegate?.didTapCategoryButton(category: self.category)
    }
}
