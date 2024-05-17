//
//  AgreementCell.swift
//  housetainer-ios
//
//  Created by 이주상 on 5/14/24.
//

import UIKit
import SnapKit

enum AgreementType: CaseIterable {
    case all, usage, info, license
    var title: String {
        switch self {
        case .all:
            "전체"
        case .usage:
            "이용약관"
        case .info:
            "개인정보 수집 이용"
        case .license:
            "최종 사용자 라이선스 계약"
        }
    }
    var textColor: UIColor {
        switch self {
        case .all:
            Color.purple500
        case .usage, .info, .license:
            Color.gray500
        }
    }
    var content: String {
        switch self {
        case .usage:
            return Bundle.main.loadRTFFile(named: "usage_agreement")
        case .info:
            return Bundle.main.loadRTFFile(named: "info_agreement")
        case .license:
            return Bundle.main.loadRTFFile(named: "eula_agreement")
        case .all:
            return ""
        }
    }
}

final class AgreementCell: UITableViewCell {
    
    var didTapTitleHandler: (()->Void)?
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapTitle)))
        label.isUserInteractionEnabled = true
        return label
    }()
    
    let checkBox: UIButton = {
        let button = UIButton()
        button.setImage(Icon.checkSquareOn, for: .selected)
        button.setImage(Icon.checkSquareOff, for: .normal)
        return button
    }()
        
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .white
        [titleLabel, checkBox].forEach { contentView.addSubview($0) }
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension AgreementCell {
    func configure(with type: AgreementType) {
        switch type {
        case .all:
            titleLabel.text = "\(type.title) 동의"
            titleLabel.textColor = type.textColor
            titleLabel.font = Typo.Body1SemiBold()
            contentView.backgroundColor = Color.gray100
            contentView.layer.cornerRadius = 8
            contentView.clipsToBounds = true
            didTapTitleHandler = nil
        case .info, .license, .usage:
            titleLabel.attributedText = NSMutableAttributedString().underlined(string: "\(type.title) 동의", font: Typo.Body2(), textColor: type.textColor, lineColor: type.textColor).requirementLabel()
            contentView.backgroundColor = .white
            contentView.layer.cornerRadius = 0
            contentView.clipsToBounds = false
        }
    }
    
    private func setupConstraints() {
        checkBox.snp.makeConstraints { make in
            make.width.height.equalTo(24)
            make.trailing.equalToSuperview().inset(16)
            make.centerY.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(16)
            make.trailing.equalTo(checkBox.snp.leading).offset(-8)
            make.centerY.equalToSuperview()
        }
    }
    
    @objc private func didTapTitle() {
        didTapTitleHandler?()
    }
}
