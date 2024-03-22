//
//  OpenHouseCell.swift
//  housetainer-ios
//
//  Created by 이주상 on 12/29/23.
//

import UIKit
import SnapKit

final class OpenHouseCell: UICollectionViewCell {    
    private let categoryLabel: UILabel = {
        let label = LabelWithPadding(topInset: 6, bottomInset: 6, leftInset: 12, rightInset: 12)
        label.font = Typo.Body6()
        label.textColor = .white
        label.backgroundColor = .black
        label.layer.cornerRadius = 4
        label.clipsToBounds = true
        return label
    }()

    private lazy var mainImage: UIImageView = {
        let view = UIImageView()
        view.backgroundColor = Color.gray300
        view.contentMode = .scaleToFill
        view.layer.cornerRadius = 10
        view.clipsToBounds = true
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = LabelFactory.build(text: "", font: Typo.Heading3())
        label.textAlignment = .left
        return label
    }()
    
    private let subTitleLabel: UILabel = {
        let label = LabelFactory.build(text: "", font: Typo.Title4())
        label.textAlignment = .left
        label.numberOfLines = 2
        return label
    }()

    private lazy var mapIcon: UIImageView = {
        UIImageView(image: Icon.map)
    }()
    
    private lazy var locationLabel: UILabel = {
        LabelFactory.build(text: "", font: Typo.Body3(), textColor: Color.gray700)
    }()

    private lazy var locationHStack: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [mapIcon, locationLabel])
        stackView.axis = .horizontal
        stackView.spacing = 4.0
        return stackView
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let label = LabelWithPadding(topInset: 12, bottomInset: 12, leftInset: 12, rightInset: 12)
        label.textColor = Color.gray700
        label.font = Typo.Body3()
        label.backgroundColor = Color.gray100
        label.numberOfLines = 2
        label.layer.cornerRadius = 8.0
        label.layer.masksToBounds = true
        return label
    }()

    private lazy var vStack: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [mainImage, titleLabel, subTitleLabel, locationHStack, descriptionLabel])
        stackView.setCustomSpacing(16.0, after: locationHStack)
        stackView.axis = .vertical
        stackView.alignment = .leading
        stackView.spacing = 6.0
        return stackView
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 0, left: 0, bottom: 30, right: 0))
    }
}

extension OpenHouseCell {
    func configure(_ house: House) {
        setUI()
        mainImage.kf.setImage(with: house.coverImageUrl)
        categoryLabel.text = house.category?.rawValue ?? "etc"
        titleLabel.text = house.title
        subTitleLabel.text = house.content
        locationLabel.text = house.location
        descriptionLabel.text = house.content
    }
    
    private func setUI() {
        [vStack, categoryLabel].forEach {
            contentView.addSubview($0)
        }
        
        mainImage.snp.makeConstraints { make in
            make.width.equalTo(UIScreen.main.bounds.width)
            make.height.equalTo(212)
        }
        
        descriptionLabel.snp.makeConstraints { make in
            make.width.equalTo(UIScreen.main.bounds.width)
        }
        
        vStack.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        categoryLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(6)
            make.leading.equalToSuperview().inset(12)
        }
    }
}
