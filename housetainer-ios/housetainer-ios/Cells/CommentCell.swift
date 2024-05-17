//
//  CommentCell.swift
//  Housetainer
//
//  Created by 이주상 on 2023/11/27.
//

import UIKit
import SnapKit

final class CommentCell: UITableViewCell {
    var optionButtonTapHandler: (() -> Void)?
    var avatarTapHandler: (() -> Void)?

    private lazy var avatar: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.layer.cornerRadius = 18
        view.layer.masksToBounds = true
        view.heightAnchor.constraint(equalToConstant: 36).isActive = true
        view.widthAnchor.constraint(equalToConstant: 36).isActive = true
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapAvatar)))
        view.isUserInteractionEnabled = true
        return view
    }()
    
    private let nicknameLabel = LabelFactory.build(text: "", font: Typo.Title6(), textColor: Color.gray700)
    private let housetainerIcon = UIImageView(image: Icon.housetainer)
    private let dateLabel = LabelFactory.build(text: "", font: Typo.Body5(), textColor: Color.gray500)

    private lazy var optionButton: UIImageView = {
        let imageView = UIImageView(image: Icon.edit)
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapOptionButton)))
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    
    private let contentsLabel: UILabel = {
        let label = LabelFactory.build(text: "", font: Typo.Body3(), textColor: Color.gray700)
        label.numberOfLines = 2
        label.textAlignment = .left
        return label
    }()

    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 0, left: 0, bottom: 24, right: 0))
    }
}

extension CommentCell {
    func configure(with comment: CommentCellData) {
        setUI()
        nicknameLabel.text = comment.nickname
        dateLabel.text = comment.createdAt
        contentsLabel.text = comment.content
        avatar.kf.setImage(with: comment.profileUrl, placeholder: Icon.nofaceXS)
        if !comment.isHousetainer {
            housetainerIcon.isHidden = true
        }
    }
    
    private func setUI() {
        backgroundColor = .white
        
        [avatar, nicknameLabel, housetainerIcon, optionButton, dateLabel, contentsLabel].forEach {
            contentView.addSubview($0)
        }
        
        avatar.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().offset(1)
        }
        
        nicknameLabel.snp.makeConstraints { make in
            make.top.equalTo(avatar.snp.top)
            make.leading.equalTo(avatar.snp.trailing).offset(6)
        }
        
        housetainerIcon.snp.makeConstraints { make in
            make.top.equalTo(avatar.snp.top)
            make.leading.equalTo(nicknameLabel.snp.trailing).offset(4)
            make.width.equalTo(11)
            make.height.equalTo(12)
        }
        
        dateLabel.snp.makeConstraints { make in
            make.top.equalTo(nicknameLabel.snp.bottom).offset(2)
            make.leading.equalTo(nicknameLabel.snp.leading)
        }
        
        optionButton.snp.makeConstraints { make in
            make.top.equalTo(avatar.snp.top)
            make.trailing.equalToSuperview().offset(-1)
        }
        
        contentsLabel.snp.makeConstraints { make in
            make.top.equalTo(avatar.snp.bottom).offset(8)
            make.leading.equalTo(nicknameLabel.snp.leading)
            make.trailing.equalToSuperview().offset(-14)
        }
    }
    
    @objc private func didTapOptionButton() {
        optionButtonTapHandler?()
    }
    
    @objc private func didTapAvatar() {
        avatarTapHandler?()
    }
}
