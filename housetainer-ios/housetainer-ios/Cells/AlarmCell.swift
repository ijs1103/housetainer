//
//  AlarmCell.swift
//  housetainer-ios
//
//  Created by 이주상 on 4/10/24.
//

import UIKit
import SnapKit

final class AlarmCell: UITableViewCell {
    
    private let alarmIcon = UIImageView()
    
    private let contentLabel: UILabel = {
        let label = LabelFactory.build(text: "", font: Typo.Body5(), textColor: Color.gray500, textAlignment: .left)
        label.numberOfLines = 2
        return label
    }()
    
    private lazy var hStack: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [alarmIcon, contentLabel])
        stackView.axis = .horizontal
        stackView.spacing = 12.0
        return stackView
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 0, left: 0, bottom: 8, right: 0))
    }
}

extension AlarmCell {
    func configure(with notification: NotificationData) {
        setupUI()
        alarmIcon.image = UIImage(named: notification.alarmType.iconName)
        contentLabel.text = (notification.nickname + notification.alarmType.text)
    }
    
    private func setupUI() {
        backgroundColor = .white
        contentView.layer.borderWidth = 1
        contentView.layer.borderColor = Color.gray100.cgColor
        contentView.layer.cornerRadius = 8
        contentView.clipsToBounds = true
        
        contentView.addSubview(hStack)
        
        hStack.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(12)
            make.trailing.equalToSuperview().offset(-12)
            make.centerY.equalToSuperview()
        }
    }
}
