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
        profileNameLabel.text = item.profileName
        
        switch item.status {
        case .invited:
            statusLabel.text = "초대완료"
            statusLabel.textColor = Color.gray500
            statusContainer.backgroundColor = Color.gray200
            profileImageView.kf.setImage(with: item.profileURL, placeholder: Icon.nofaceS)
        case .expired:
            statusLabel.text = "만료"
            statusLabel.textColor = Color.red200
            statusContainer.backgroundColor = Color.red100
            profileImageView.kf.setImage(with: item.profileURL, placeholder: Icon.nofaceS)
        case .sent:
            statusLabel.text = "초대중"
            statusLabel.textColor = Color.blue200
            statusContainer.backgroundColor = Color.blue100
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
    
    private let profileNameLabel = {
        let label = UILabel()
        label.font = Typo.Body3()
        label.textColor = Color.black
        label.text = "김김김"
        return label
    }()
    
    private let statusContainer = {
        let view = UIView()
        view.layoutMargins = UIEdgeInsets(top: 6, left: 12, bottom: 6, right: 12)
        view.layer.cornerRadius = 4
        view.layer.masksToBounds = true
        return view
    }()
    private let statusLabel = {
        let label = UILabel()
        label.font = Typo.Body7()
        return label
    }()
}

private extension MyPageBuddyCollectionViewCell{
    func setupUI(){
        contentView.backgroundColor = Color.gray100
        contentView.layer.cornerRadius = 8
        contentView.addSubview(profileImageView)
        contentView.addSubview(profileNameLabel)
        contentView.addSubview(statusContainer)
        statusContainer.addSubview(statusLabel)

        profileImageView.snp.makeConstraints{
            $0.size.equalTo(64)
            $0.centerX.equalToSuperview()
            $0.leading.greaterThanOrEqualToSuperview().inset(19.5)
            $0.trailing.lessThanOrEqualToSuperview().inset(19.5)
            $0.top.equalToSuperview().inset(12)
        }
        
        profileNameLabel.snp.makeConstraints{
            $0.centerX.equalToSuperview()
            $0.top.equalTo(profileImageView.snp.bottom).offset(4)
        }
        
        statusContainer.snp.makeConstraints{
            $0.centerX.equalToSuperview()
            $0.top.greaterThanOrEqualTo(profileNameLabel.snp.bottom).offset(-13)
            $0.bottom.equalToSuperview().inset(12)
        }
        
        statusLabel.snp.makeConstraints{
            $0.top.equalTo(statusContainer.snp.topMargin)
            $0.trailing.equalTo(statusContainer.snp.trailingMargin)
            $0.bottom.equalTo(statusContainer.snp.bottomMargin)
            $0.leading.equalTo(statusContainer.snp.leadingMargin)
        }
    }
}

extension MyPageBuddyCollectionViewCell{
    struct Item: Equatable{
        let id: String
        let profileURL: URL?
        let profileName: String
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
                profileName: "김길동",
                status: .expired)
            )
            return cell
        }
    }
}

