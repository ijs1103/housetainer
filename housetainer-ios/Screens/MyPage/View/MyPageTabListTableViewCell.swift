//
//  MyPageTabListTableViewCell.swift
//  housetainer-ios
//
//  Created by 김수아 on 1/7/24.
//


import Foundation
import UIKit
import SwiftUI
import SnapKit
import Kingfisher

final class MyPageTabListTableViewCell: UITableViewCell{
    var didTapBookmark: (() -> Void)?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
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
        pinImageView.isHidden = !item.isBookmarked
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
        imageView.isUserInteractionEnabled = true
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
    private lazy var pinImageView = {
        let imageView = UIImageView()
        imageView.image = Icon.pickOn
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapBookmarkAction)))
        return imageView
    }()
    
    private let contentStack = {
        let stack = UIStackView()
        stack.axis = .vertical
        return stack
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

private extension MyPageTabListTableViewCell{
    func setupUI(){
        selectionStyle = .none
        contentView.layoutMargins = UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20)
        contentView.addSubview(mainImageView)
        mainImageView.addSubview(badgeContainer)
        badgeContainer.addSubview(badgeLabel)
        mainImageView.addSubview(pinImageView)
        contentView.addSubview(contentStack)
        contentStack.addArrangedSubview(titleLabel)
        contentStack.addArrangedSubview({
            let view = UIView()
            view.snp.makeConstraints{
                $0.height.equalTo(6)
            }
            return view
        }())
        contentStack.addArrangedSubview(nicknameLabel)
        contentStack.addArrangedSubview({
            let view = UIView()
            view.snp.makeConstraints{
                $0.height.equalTo(8)
            }
            return view
        }())
        contentStack.addArrangedSubview(dateLabel)
        
        mainImageView.snp.makeConstraints{
            $0.leading.equalTo(contentView.snp.leadingMargin)
            $0.top.equalTo(contentView.snp.topMargin)
            $0.bottom.equalTo(contentView.snp.bottomMargin)
            $0.width.equalTo(160)
            $0.height.equalTo(184)
        }
        
        badgeContainer.snp.makeConstraints{
            $0.top.leading.equalToSuperview().inset(12)
            $0.trailing.lessThanOrEqualTo(pinImageView.snp.leading).offset(-12)
        }
        
        badgeLabel.snp.makeConstraints{
            $0.directionalEdges.equalTo(badgeContainer.snp.directionalMargins)
        }
        
        pinImageView.snp.makeConstraints{
            $0.top.trailing.equalToSuperview().inset(12)
            $0.width.height.equalTo(26)
        }
        
        contentStack.snp.makeConstraints{
            $0.top.greaterThanOrEqualTo(contentView.snp.topMargin)
            $0.leading.equalTo(mainImageView.snp.trailing).offset(20)
            $0.trailing.lessThanOrEqualToSuperview()
            $0.bottom.lessThanOrEqualTo(contentView.snp.bottomMargin)
            $0.centerY.equalToSuperview()
        }
    }
    
    @objc func didTapBookmarkAction(){
        didTapBookmark?()
    }
}

extension MyPageTabListTableViewCell{
    struct Item{
        let id: String
        let mainURL: URL?
        let badge: String
        let title: String
        let nickname: String
        let isHouseTainer: Bool
        let date: String
        let isBookmarked: Bool
    }
}

struct MyPageTabListTableViewCell_Previews: PreviewProvider{
    static var previews: some View{
        ViewPreview{
            let cell = MyPageTabListTableViewCell()
            cell.update(with: .init(
                id: "",
                mainURL: URL(string: "https://placekitten.com/200/200")!,
                badge: "행사행사행사행사행사행사행사행사행사행사행사행사행사행사행사행사행사행사행사",
                title: "김길동",
                nickname: "닉네임",
                isHouseTainer: true,
                date: "23.08.01",
                isBookmarked: true
            ))
            return cell
        }
    }
}
