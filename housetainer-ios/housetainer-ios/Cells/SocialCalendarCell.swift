//
//  SocialCalendarCell.swift
//  housetainer-ios
//
//  Created by 이주상 on 12/28/23.
//

import UIKit
import SnapKit

final class SocialCalendarCell: UICollectionViewCell {
    private var event: EventDetail?

    private let categoryLabel: UILabel = {
        let label = LabelWithPadding(topInset: 8, bottomInset: 8, leftInset: 12, rightInset: 12)
        label.font = Typo.Body3()
        label.textColor = .white
        label.backgroundColor = Color.purple400
        label.layer.cornerRadius = 4
        label.clipsToBounds = true
        label.text = "Host"
        return label
    }()
    
    private lazy var mainImage: UIImageView = {
        let view = UIImageView()
        view.backgroundColor = Color.gray300
        view.contentMode = .scaleToFill
        view.layer.cornerRadius = 10
        view.clipsToBounds = true
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = LabelFactory.build(text: "", font: Typo.Title4())
        label.numberOfLines = 2
        label.textAlignment = .left
        return label
    }()
    
    private lazy var avatar: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleToFill
        view.layer.cornerRadius = 18
        view.layer.masksToBounds = true
        return view
    }()
    
    private let nicknameLabel: UILabel = {
        LabelFactory.build(text: "", font: Typo.Body3(), textColor: Color.gray700)
    }()
    
    private let housetainerIcon = UIImageView(image: Icon.housetainer)
    
    private let dateLabel: UILabel = {
        LabelFactory.build(text: "", font: Typo.Body5(), textColor: Color.gray500)
    }()

    private lazy var subHStack: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [nicknameLabel, housetainerIcon])
        stackView.axis = .horizontal
        stackView.spacing = 4.0
        return stackView
    }()
    
    private lazy var subVStack: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [subHStack, dateLabel])
        stackView.axis = .vertical
        stackView.spacing = 2.0
        stackView.alignment = .leading
        return stackView
    }()
    
    private lazy var nicknameHStack: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [avatar, subVStack])
        stackView.axis = .horizontal
        stackView.spacing = 6.0
        return stackView
    }()

    private lazy var vStack: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [mainImage, titleLabel, nicknameHStack])
        stackView.setCustomSpacing(16.0, after: mainImage)
        stackView.axis = .vertical
        stackView.spacing = 6.0
        return stackView
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 0, left: 0, bottom: 28, right: 0))
    }
}

extension SocialCalendarCell {
    func configure(_ event: EventDetail) {
        self.event = event
        setUI()
        mainImage.kf.setImage(with: event.imageUrl)
        avatar.kf.setImage(with: event.profileUrl, placeholder: Icon.nofaceXS)
        categoryLabel.text = event.scheduleType
        titleLabel.text = event.title
        nicknameLabel.text = event.nickname
        dateLabel.text = event.date
        if !event.isHousetainer {
            housetainerIcon.isHidden = true
        }
    }
    
    private func setUI() {
        backgroundColor = .white
        
        [vStack, categoryLabel].forEach {
            contentView.addSubview($0)
        }
        
        mainImage.snp.makeConstraints { make in
            make.height.equalTo(212)
        }
        
        avatar.snp.makeConstraints { make in
            make.width.height.equalTo(36)
        }
        
        housetainerIcon.snp.makeConstraints { make in
            make.width.equalTo(11)
            make.height.equalTo(12)
        }
        
        vStack.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        categoryLabel.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().inset(12)
        }
    }
}
