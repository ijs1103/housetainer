//
//  CommentCell.swift
//  Housetainer
//
//  Created by 이주상 on 2023/11/27.
//

import UIKit
import SnapKit

final class CommentCell: UITableViewCell {
    
    private let avatar: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.layer.cornerRadius = 18
        view.layer.masksToBounds = true
        return view
    }()
    
    private let nicknameLabel: UILabel = {
        LabelFactory.build(text: "", font: Typo.Title6(), textColor: Color.gray700)
    }()
    
    private let housetainerIcon: UIImageView = {
        UIImageView(image: Icon.housetainer)
    }()
    
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
    
    private let contents: UILabel = {
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
        contents.text = comment.content
        avatar.kf.setImage(with: comment.profileUrl, placeholder: Icon.nofaceXS)
        if !comment.isHousetainer {
            housetainerIcon.isHidden = true
        }
    }
    
    private func setUI() {
        backgroundColor = .white
        
        [nicknameHStack, contents].forEach {
            addSubview($0)
        }

        avatar.snp.makeConstraints { make in
            make.width.height.equalTo(36)
        }
        
        housetainerIcon.snp.makeConstraints { make in
            make.width.equalTo(11)
            make.height.equalTo(12)
        }
        
        nicknameHStack.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
        }
        
        contents.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(41)
            make.trailing.equalToSuperview().inset(14)
            make.top.equalTo(nicknameHStack.snp.bottom).offset(8)
        }
    }
}
