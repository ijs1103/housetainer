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
        profileImageView.kf.setImage(with: item.profileURL, placeholder: Icon.nofaceS)
        profileNameLabel.attributedText = NSAttributedString{
            NSAttributedString(string: item.profileName)
            NSAttributedString.spacing(width: 4)
            if item.isHouseTainer{
                NSAttributedString.image(Icon.housetainer!)
            }
        }
        
        editProfileButton.isHidden = !item.isEditable
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
    private let stackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        return stackView
    }()
    
    private let dividers: [UIView] = [
        {
            let divider = UIView()
            divider.backgroundColor = Color.gray300
            divider.snp.makeConstraints{
                $0.height.equalTo(1)
            }
            return divider
        }(),
        {
            let divider = UIView()
            divider.backgroundColor = Color.gray200
            divider.snp.makeConstraints{
                $0.height.equalTo(8)
            }
            return divider
        }(),
        {
            let divider = UIView()
            divider.backgroundColor = Color.white
            divider.snp.makeConstraints{
                $0.height.equalTo(34)
            }
            return divider
        }()
    ]
    
    private let container = UIView()
    
    private let profileImageView = {
        let imageView = InternalImageView()
        imageView.image = Icon.nofaceS
        imageView.layer.masksToBounds = true
        imageView.didLayout = { [weak imageView] in
            guard let imageView else{ return }
            imageView.layer.cornerRadius = imageView.frame.width / 2
        }
        return imageView
    }()
    
    private let profileNameLabel = {
        let label = UILabel()
        label.text = ""
        return label
    }()
    
    private lazy var editProfileButton = {
        let button = UIButton()
        button.titleLabel?.font = Typo.Body5()
        button.backgroundColor = Color.gray200
        button.setTitle("프로필 수정", for: .normal)
        button.setTitleColor(Color.gray700, for: .normal)
        button.layer.cornerRadius = 4
        button.layer.masksToBounds = true
        button.isHidden = true
        button.addTarget(self, action: #selector(didTapEditProfileButtonAction), for: .touchUpInside)
        return button
    }()
}

private extension MyPageHeaderView{
    func setupUI(){
        backgroundColor = UIColor.white
        addSubview(stackView)
        container.addSubview(profileImageView)
        container.addSubview(profileNameLabel)
        container.addSubview(editProfileButton)
        
        stackView.addArrangedSubview(container)
        dividers.forEach{
            stackView.addArrangedSubview($0)
        }
        
        stackView.snp.makeConstraints{
            $0.edges.equalToSuperview()
        }
        
        profileImageView.snp.makeConstraints{
            $0.width.height.equalTo(64)
            $0.centerY.equalToSuperview()
            $0.top.greaterThanOrEqualTo(21)
            $0.bottom.lessThanOrEqualTo(-21)
            $0.leading.equalToSuperview().inset(20)
        }
        
        profileNameLabel.snp.makeConstraints{
            $0.leading.equalTo(profileImageView.snp.trailing).offset(17)
            $0.centerY.equalToSuperview()
            $0.trailing.lessThanOrEqualTo(editProfileButton.snp.leading).offset(-17)
        }
        
        editProfileButton.snp.makeConstraints{
            $0.width.equalTo(100)
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().inset(20)
        }
    }
    
    @objc func didTapEditProfileButtonAction(){
        didTapEditProfile?()
    }
}

extension MyPageHeaderView{
    struct Item{
        let profileURL: URL?
        let profileName: String
        let isEditable: Bool
        let isHouseTainer: Bool
    }
}

struct MyPageHeaderView_Previews: PreviewProvider{
    static var previews: some View{
        ViewPreview{
            let view = MyPageHeaderView()
            view.update(with: .init(
                profileURL: URL(string: "https://placekitten.com/200/200")!,
                profileName: "김길동김길동김길동김길동김길동김길동김길동김길동김길동김길동김길동김길동김길동김길동김길동김길동",
                isEditable: false,
                isHouseTainer: true
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
