//
//  MyPagePublicBuddyCollectionViewCell.swift
//  housetainer-ios
//
//  Created by 김수아 on 1/9/24.
//

import Foundation
import UIKit
import SnapKit
import SwiftUI

final class MyPagePublicBuddyCollectionViewCell: UICollectionViewCell{
    
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
        
        profileNameLabel.text = item.profileName
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
    
    // MARK: - Private
}

private extension MyPagePublicBuddyCollectionViewCell{
    func setupUI(){
        backgroundColor = .clear
        contentView.addSubview(profileImageView)
        contentView.addSubview(profileNameLabel)

        profileImageView.snp.makeConstraints{
            $0.size.equalTo(64)
            $0.centerX.equalToSuperview()
            $0.leading.greaterThanOrEqualToSuperview().inset(20)
            $0.trailing.lessThanOrEqualToSuperview().inset(20)
            $0.top.equalToSuperview().inset(12)
        }
        
        profileNameLabel.snp.makeConstraints{
            $0.centerX.equalToSuperview()
            $0.top.equalTo(profileImageView.snp.bottom).offset(4)
            $0.bottom.lessThanOrEqualToSuperview().inset(12)
        }
    }
}

extension MyPagePublicBuddyCollectionViewCell{
    struct Item: Equatable{
        let id: String
        let profileURL: URL?
        let profileName: String
    }
}

struct MyPagePublicBuddyCollectionViewCell_Previews: PreviewProvider{
    static var previews: some View{
        ViewPreview{
            let cell = MyPagePublicBuddyCollectionViewCell()
            cell.update(with: .init(
                id: "",
                profileURL: URL(string: "https://placekitten.com/200/200")!,
                profileName: "김길동"
            ))
            return cell
        }
    }
}

