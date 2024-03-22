//
//  MyPageCalendarCollectionViewCell.swift
//  housetainer-ios
//
//  Created by 김수아 on 1/4/24.
//

import Foundation
import UIKit
import SwiftUI
import SnapKit
import Kingfisher

final class MyPageCalendarCollectionViewCell: UICollectionViewCell{
    
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
        nicknameLabel.attributedText = NSAttributedString{
            NSAttributedString(string: item.nickname)
            NSAttributedString.spacing(width: 4)
            if item.isHouseTainer{
                NSAttributedString.image(Icon.housetainer!)
            }
        }
        dateLabel.text = item.date
        setNeedsUpdateConstraints()
    }
    
    func updateWidth(_ width: CGFloat){
        mainImageView.snp.makeConstraints{
            $0.width.equalTo(width)
        }
        setNeedsUpdateConstraints()
    }
    
    // MARK: - UI Properties
    private let mainImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 16
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    private let badgeContainer = {
        let view = UIView()
        view.backgroundColor = Color.yellow100
        view.layoutMargins = UIEdgeInsets(top: 6, left: 12, bottom: 6, right: 12)
        view.layer.cornerRadius = 4
        view.layer.masksToBounds = true
        return view
    }()
    private let badgeLabel = {
        let label = UILabel()
        label.font = Typo.Body6()
        label.textColor = Color.yellow300
        label.numberOfLines = 0
        return label
    }()
    
    private let titleLabel = {
        let label = UILabel()
        label.font = Typo.Body3()
        label.textColor = Color.black
        label.numberOfLines = 0
        return label
    }()
    
    private let nicknameLabel = {
        let label = UILabel()
        label.font = Typo.Body3()
        label.textColor = Color.gray700
        label.numberOfLines = 0
        return label
    }()
    
    private let dateLabel = {
        let label = UILabel()
        label.font = Typo.Body5()
        label.textColor = Color.gray500
        label.numberOfLines = 0
        return label
    }()
}

private extension MyPageCalendarCollectionViewCell{
    func setupUI(){
        contentView.addSubview(mainImageView)
        mainImageView.addSubview(badgeContainer)
        badgeContainer.addSubview(badgeLabel)
        contentView.addSubview(titleLabel)
        contentView.addSubview(nicknameLabel)
        contentView.addSubview(dateLabel)
        
        mainImageView.snp.makeConstraints{
            $0.top.horizontalEdges.equalToSuperview()
            $0.height.equalTo(200)
        }
        
        badgeContainer.snp.makeConstraints{
            $0.top.leading.equalToSuperview().inset(12)
            $0.trailing.lessThanOrEqualToSuperview().offset(-12)
        }
        
        badgeLabel.snp.makeConstraints{
            $0.directionalEdges.equalTo(badgeContainer.snp.directionalMargins)
        }
        
        titleLabel.snp.makeConstraints{
            $0.top.equalTo(mainImageView.snp.bottom).offset(8)
            $0.leading.equalToSuperview()
            $0.trailing.lessThanOrEqualToSuperview()
        }
        
        nicknameLabel.snp.makeConstraints{
            $0.top.equalTo(titleLabel.snp.bottom).offset(6)
            $0.leading.equalTo(titleLabel.snp.leading)
            $0.trailing.lessThanOrEqualToSuperview()
        }
        
        dateLabel.snp.makeConstraints{
            $0.top.equalTo(nicknameLabel.snp.bottom).offset(8)
            $0.leading.equalTo(nicknameLabel.snp.leading)
            $0.trailing.lessThanOrEqualToSuperview()
            $0.bottom.equalToSuperview()
        }
    }
}

extension MyPageCalendarCollectionViewCell{
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

struct MyPageCalendarCollectionViewCell_Previews: PreviewProvider{
    static var previews: some View{
        ViewPreview{
            let cell = MyPageCalendarCollectionViewCell()
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


