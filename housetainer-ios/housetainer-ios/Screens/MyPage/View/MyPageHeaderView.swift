//
//  MyPageHeaderView.swift
//  housetainer-ios
//
//  Created by 김수아 on 1/2/24.
//

import Foundation
import UIKit
import SwiftUI
import Kingfisher

final class MyPageHeaderView: UIView{
    var didTapEditProfile: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update(with item: Item){
        profileImageView.setImage(item.profileRef, placeholder: Icon.nofaceS)
        profileNameLabel.attributedText = NSAttributedString{
            NSAttributedString(string: item.profileName)
            NSAttributedString.spacing(width: 5)
            if item.isHouseTainer{
                NSAttributedString.image(Icon.housetainer!)
            }
        }
        profileFooterLabel.attributedText = NSAttributedString{
            NSAttributedString(string: "invited by", attributes: [
                .font: UIFont.name(.regular, size: 12),
                .foregroundColor: Color.reddishPurple400
            ])
            NSAttributedString(string: " \(item.inviterNickname ?? "인터스타일")", attributes: [
                .font: Typo.Caption1(),
                .foregroundColor: Color.gray700
            ])
        }
        //editProfileButton.isHidden = !item.isEditable
        editProfileButton.snp.updateConstraints{
            if item.isEditable{
                $0.width.equalTo(100)
                $0.trailing.equalToSuperview().inset(20)
            }else{
                $0.width.equalTo(0)
                $0.trailing.equalToSuperview()
            }
        }
    }
    
    // MARK: - UI Properties
    private let profileImageView = {
        let imageView = InternalImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.image = Icon.nofaceS
        imageView.layer.masksToBounds = true
        imageView.didLayout = { [weak imageView] in
            guard let imageView else{ return }
            imageView.layer.cornerRadius = imageView.frame.width / 2
        }
        return imageView
    }()
    
    private let stackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 2
        return stackView
    }()
    
    private let profileNameLabel = LabelFactory.build(text: "", font: Typo.Body1Medium(), textColor: Color.gray800, textAlignment: .left)
    
    private let profileFooterLabel = {
        let label = UILabel()
        
        return label
    }()
    
    private lazy var editProfileButton = {
        let button = UIButton()
        button.contentEdgeInsets = .init(top: 12, left: 16, bottom: 12, right: 16)
        button.titleLabel?.font = Typo.Body3()
        button.setTitle("프로필 수정", for: .normal)
        button.setTitleColor(Color.reddishPurple500, for: .normal)
        button.layer.borderWidth = 1
        button.layer.borderColor = Color.reddishPurple400.cgColor
        button.layer.cornerRadius = 4
        button.layer.masksToBounds = true
        //button.isHidden = true
        button.addTarget(self, action: #selector(didTapEditProfileButtonAction), for: .touchUpInside)
        return button
    }()
    
    private let underlineView = {
        let view = UIView()
        view.backgroundColor = Color.gray150
        return view
    }()
}

extension MyPageHeaderView {
    func hideEditButton() {
        editProfileButton.isHidden = true
    }
}

private extension MyPageHeaderView{
    func setupUI(){
        backgroundColor = UIColor.white
        addSubview(profileImageView)
        addSubview(stackView)
        stackView.addArrangedSubview(profileNameLabel)
        stackView.addArrangedSubview(profileFooterLabel)
        addSubview(editProfileButton)
        addSubview(underlineView)
        
        profileImageView.snp.makeConstraints{
            $0.width.height.equalTo(60)
            $0.top.equalToSuperview().inset(20)
            $0.bottom.equalToSuperview().inset(28)
            $0.leading.equalToSuperview().inset(20)
        }
        
        stackView.snp.makeConstraints{
            $0.leading.equalTo(profileImageView.snp.trailing).offset(12)
            $0.centerY.equalTo(profileImageView.snp.centerY)
            $0.trailing.lessThanOrEqualTo(editProfileButton.snp.leading).offset(-17)
        }
        
        editProfileButton.snp.makeConstraints{
            $0.width.equalTo(95)
            $0.centerY.equalTo(stackView.snp.centerY)
            $0.trailing.equalToSuperview().inset(20)
        }
        
        underlineView.snp.makeConstraints{
            $0.height.equalTo(0.75)
            $0.directionalHorizontalEdges.bottom.equalToSuperview()
        }
    }
    
    @objc func didTapEditProfileButtonAction(){
        didTapEditProfile?()
    }
}

extension MyPageHeaderView{
    struct Item{
        let profileRef: ImageReference?
        let profileName: String
        let isEditable: Bool
        let isHouseTainer: Bool
        let inviterNickname: String?
    }
}

struct MyPageHeaderView_Previews: PreviewProvider{
    static var previews: some View{
        ViewPreview{
            let view = MyPageHeaderView()
            view.update(with: .init(
                profileRef: .url(URL(string: "https://placekitten.com/200/200")!),
                profileName: "김길동김길동김길동김길동김길동김길동김길동김길동김길동김길동김길동김길동김길동김길동김길동김길동",
                isEditable: false,
                isHouseTainer: true,
                inviterNickname: nil
            ))
            return view
        }
    }
}

private final class InternalImageView: UIImageView{
    var didLayout: (() -> Void)?
    
    override func layoutSubviews() {
        super.layoutSubviews()
        didLayout?()
    }
}
