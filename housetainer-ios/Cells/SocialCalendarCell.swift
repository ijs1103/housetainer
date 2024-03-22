//
//  SocialCalendarCell.swift
//  housetainer-ios
//
//  Created by 이주상 on 12/28/23.
//

import UIKit
import SnapKit

protocol SocialCalendarCellDelegate: AnyObject {
    func didTapLikeButton(event: EventDetail, toggleLikeButtonImage: @escaping () -> Void)
}

final class SocialCalendarCell: UICollectionViewCell {
    weak var delegate: SocialCalendarCellDelegate?
    private var event: EventDetail?

    private let categoryLabel: UILabel = {
        let label = LabelWithPadding(topInset: 6, bottomInset: 6, leftInset: 12, rightInset: 12)
        label.font = Typo.Body6()
        label.textColor = Color.yellow300
        label.backgroundColor = Color.yellow100
        label.layer.cornerRadius = 4
        label.clipsToBounds = true
        return label
    }()
    
    private lazy var likeButton: UIImageView = {
        let view = UIImageView(image: Icon.pickOff)
        let tgr = UITapGestureRecognizer(target: self, action: #selector(didTapLikeButton))
        view.addGestureRecognizer(tgr)
        view.isUserInteractionEnabled = true
        return view
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
        dateLabel.text = event.createdAt
        if !event.isHousetainer {
            housetainerIcon.isHidden = true
        }
        Task {
            let isLiked = await event.isLiked()
            likeButton.image = isLiked ? Icon.pickOn : Icon.pickOff
        }
    }
    
    private func setUI() {
        backgroundColor = .white
        
        [vStack, categoryLabel, likeButton].forEach {
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
        
        likeButton.snp.makeConstraints { make in
            make.top.trailing.equalToSuperview().inset(12)
        }
    }
    
    private func toggleLikeButtonImage() {
        likeButton.image = (likeButton.image == Icon.pickOn) ? Icon.pickOff : Icon.pickOn
    }
    
    @objc private func didTapLikeButton() {
        guard let event else { return }
        delegate?.didTapLikeButton(event: event, toggleLikeButtonImage: toggleLikeButtonImage)
    }
}
