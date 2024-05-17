//
//  CheckBoxInput.swift
//  housetainer-ios
//
//  Created by 이주상 on 4/2/24.
//

import UIKit
import SnapKit

final class CheckBoxInput: UIView {
        
    var isChecked: Bool = false {
        didSet {
            toggleStatus(isChecked: isChecked)
        }
    }
    
    private let checkBox = UIImageView(image: Icon.checkCircleOff)
    
    private let titleLabel: UILabel = {
        LabelFactory.build(text: Title.agree, font: Typo.Body2(), textColor: Color.gray800)
    }()
    
    private lazy var hStack: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [checkBox, titleLabel])
        stackView.axis = .horizontal
        stackView.spacing = 12
        return stackView
    }()
    
    init(title: String) {
        super.init(frame: .zero)
        setUI()
        setTitle(title)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension CheckBoxInput {
    private func setUI() {
        backgroundColor = .white
        layer.borderWidth = 1
        layer.borderColor = Color.gray150.cgColor
        layer.cornerRadius = 8
        clipsToBounds = true
        
        addSubview(hStack)
        
        hStack.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(18)
            make.top.equalToSuperview().offset(12)
            make.bottom.equalToSuperview().offset(-12)
        }
    }
    
    func getTitle() -> String? {
        titleLabel.text
    }
    
    private func setTitle(_ title: String) {
        titleLabel.text = title
    }
    
    private func toggleStatus(isChecked: Bool) {
        if isChecked {
            checkBox.image = Icon.checkCircleOn
            layer.borderColor = Color.purple100.cgColor
        } else {
            checkBox.image = Icon.checkCircleOff
            layer.borderColor = Color.gray150.cgColor
        }
    }
}
