//
//  MyPageIPickSocialCalendarCollectionViewCell.swift
//  housetainer-ios
//
//  Created by 김수아 on 1/4/24.
//

import Foundation
import UIKit
import SwiftUI
import SnapKit
import Kingfisher

final class MyPageIPickSocialCalendarCollectionViewCell: UICollectionViewCell{
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update(with item: Item){
        mainImageView.kf.setImage(with: item.mainURL)
        badgeLabel.text = item.badge
        titleLabel.text = item.title
        dateLabel.text = item.date
        nicknameLabel.attributedText = NSAttributedString{
            NSAttributedString(string: item.nickname)
            if item.isHouseTainer{
                NSAttributedString.image(Icon.housetainer!)
            }
        }
        setNeedsUpdateConstraints()
    }
    
    override func updateConstraints() {
        mainImageView.snp.updateConstraints{
            $0.height.equalTo(160)
        }
        
        badgeContainer.snp.updateConstraints{
            $0.top.leading.equalToSuperview().inset(12)
            $0.trailing.lessThanOrEqualToSuperview().inset(12)
        }
        
        badgeLabel.snp.updateConstraints{
            $0.directionalEdges.equalTo(badgeContainer.snp.directionalMargins)
        }
        
        titleLabel.snp.updateConstraints{
            $0.top.equalTo(mainImageView.snp.bottom).offset(8)
            $0.directionalHorizontalEdges.equalToSuperview()
        }
        
        dateLabel.snp.updateConstraints{
            $0.top.equalTo(titleLabel.snp.bottom).offset(2)
            $0.leading.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
        
        nicknameLabel.snp.updateConstraints{
            $0.top.equalTo(titleLabel.snp.bottom).offset(2)
            $0.leading.equalTo(dateLabel.snp.trailing).offset(12)
            $0.trailing.lessThanOrEqualToSuperview().inset(19)
            $0.bottom.equalToSuperview()
        }
        
        super.updateConstraints()
    }
    
    // MARK: - UI Properties
    private let mainImageView = {
        let imageView = HTImageView(frame: .zero)
        imageView.layer.cornerRadius = 16
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.layer.addSublayer({
            let layer = CAGradientLayer()
            layer.colors = [
                Color.black.withAlphaComponent(0).cgColor,
                Color.black.withAlphaComponent(0.22).cgColor,
                Color.black.withAlphaComponent(0.7).cgColor
            ]
            layer.locations = [
                0, 0.61, 1
            ]
            return layer
        }())
        imageView.didLayout = { [weak imageView] in
            guard let imageView else{ return }
            for sublayer in imageView.layer.sublayers ?? []{
                sublayer.frame = imageView.bounds
            }
        }
        return imageView
    }()
    private let badgeContainer = {
        let view = UIView()
        view.backgroundColor = Color.reddishPurple400
        view.layoutMargins = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)
        view.layer.cornerRadius = 4
        view.layer.masksToBounds = true
        return view
    }()
    private let badgeLabel = {
        let label = UILabel()
        label.font = Typo.Body3()
        label.textColor = Color.white
        label.numberOfLines = 0
        return label
    }()
    
    private let titleLabel = {
        let label = UILabel()
        label.font = Typo.Body2Medium()
        label.textColor = Color.gray800
        label.numberOfLines = 2
        return label
    }()
    
    private let dateLabel = {
        let label = UILabel()
        label.font = Typo.Body3()
        label.textColor = Color.gray600
        label.numberOfLines = 1
        return label
    }()
    
    private let nicknameLabel = {
        let label = UILabel()
        label.font = Typo.Body3()
        label.textColor = Color.gray600
        label.numberOfLines = 1
        return label
    }()
}

private extension MyPageIPickSocialCalendarCollectionViewCell{
    func setupUI(){
        contentView.addSubview(mainImageView)
        contentView.addSubview(badgeContainer)
        badgeContainer.addSubview(badgeLabel)
        contentView.addSubview(titleLabel)
        contentView.addSubview(dateLabel)
        contentView.addSubview(nicknameLabel)
        
        mainImageView.snp.updateConstraints{
            $0.top.directionalHorizontalEdges.equalToSuperview()
            $0.height.equalTo(160)
        }
    }
}

extension MyPageIPickSocialCalendarCollectionViewCell{
    struct Item{
        let id: String
        let mainURL: URL?
        let badge: String
        let title: String
        let nickname: String
        let isHouseTainer: Bool
        let date: String
    }
}

struct MyPageIPickSocialCalendarCollectionViewCell_Previews: PreviewProvider{
    static var previews: some View{
        ViewPreview{
            let cell = MyPageIPickSocialCalendarCollectionViewCell()
            cell.update(with: .init(
                id: "",
                mainURL: URL(string: "https://placekitten.com/200/200")!,
                badge: "행사행사행사행사행사행사행사행사행사행사행사행사행사행사행사행사행사행사행사행사행사행사",
                title: "김길동",
                nickname: "닉네임",
                isHouseTainer: true,
                date: "23.08.01"
            ))
            return cell
        }
    }
}


