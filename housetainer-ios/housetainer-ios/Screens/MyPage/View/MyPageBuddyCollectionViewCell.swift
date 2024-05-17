//
//  MyPageBuddyCollectionViewCell.swift
//  housetainer-ios
//
//  Created by 김수아 on 1/3/24.
//

import Foundation
import UIKit
import SwiftUI
import SnapKit
import Kingfisher

final class MyPageBuddyCollectionViewCell: UICollectionViewCell{
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update(with item: Item){
        emailLabel.text = item.email
        
        switch item.status {
        case .invited:
            statusLabel.text = "활동중"
            statusLabel.textColor = Color.purple400
            statusContainer.backgroundColor = Color.purple100
            profileImageView.kf.setImage(with: item.profileURL, placeholder: Icon.nofaceS)
        case .expired:
            statusLabel.text = "만료"
            statusLabel.textColor = Color.gray500
            statusContainer.backgroundColor = Color.gray200
            profileImageView.kf.setImage(with: item.profileURL, placeholder: Icon.nofaceS)
        case .sent:
            statusLabel.text = "초대중"
            statusLabel.textColor = UIColor(rgb: 0x10B954)
            statusContainer.backgroundColor = UIColor(rgb: 0xD0F5E3)
            profileImageView.kf.setImage(with: item.profileURL, placeholder: Icon.invite)
        }
    }
    
    // MARK: - UI Properties
    private lazy var profileImageView = {
        let imageView = HTImageView(frame: .zero)
        imageView.image = Icon.nofaceS
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        imageView.didLayout = { [weak imageView] in
            guard let imageView else{ return }
            imageView.layer.cornerRadius = imageView.frame.height / 2
        }
        return imageView
    }()
    
    private let emailLabel = {
        let label = UILabel()
        label.font = Typo.Body3()
        label.textColor = Color.gray800
        label.text = ""
        return label
    }()
    
    private let statusContainer = {
        let view = UIView()
        view.layoutMargins = UIEdgeInsets(top: 4, left: 8, bottom: 4, right: 8)
        view.layer.cornerRadius = 4
        view.layer.masksToBounds = true
        return view
    }()
    private let statusLabel = {
        let label = UILabel()
        label.font = Typo.Caption1()
        return label
    }()
}

private extension MyPageBuddyCollectionViewCell{
    func setupUI(){
        contentView.backgroundColor = Color.gray100
        contentView.layer.cornerRadius = 8
        contentView.addSubview(profileImageView)
        contentView.addSubview(emailLabel)
        contentView.addSubview(statusContainer)
        statusContainer.addSubview(statusLabel)

        profileImageView.snp.makeConstraints{
            $0.size.equalTo(64)
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview().inset(16)
        }
        
        emailLabel.snp.makeConstraints{
            $0.centerX.equalToSuperview()
            $0.top.equalTo(profileImageView.snp.bottom).offset(12)
        }
        
        statusContainer.snp.makeConstraints{
            $0.centerX.equalToSuperview()
            $0.top.greaterThanOrEqualTo(emailLabel.snp.bottom).offset(20)
            $0.bottom.equalToSuperview().inset(18)
        }
        
        statusLabel.snp.makeConstraints{
            $0.directionalEdges.equalTo(statusContainer.snp.directionalMargins)
        }
    }
}

extension MyPageBuddyCollectionViewCell{
    struct Item: Equatable{
        let id: String
        let profileURL: URL?
        let email: String
        let status: InvitationStatus
    }
}

struct MyPageBuddyCollectionViewCell_Previews: PreviewProvider{
    static var previews: some View{
        ViewPreview{
            let cell = MyPageBuddyCollectionViewCell()
            cell.update(with: .init(
                id: "",
                profileURL: URL(string: "https://placekitten.com/200/200")!,
                email: "김길동",
                status: .expired)
            )
            return cell
        }
    }
}

