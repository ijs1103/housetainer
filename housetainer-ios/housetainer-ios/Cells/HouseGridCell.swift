//
//  HouseGridCell.swift
//  Housetainer
//
//  Created by 이주상 on 2023/11/18.
//

import UIKit
import SnapKit
import Kingfisher

final class HouseGridCell: UICollectionViewCell {
    
    static let width: CGFloat = (UIScreen.main.bounds.width - 50.0) / 2
        
    private lazy var imageView: UIImageView = {
        let view = UIImageView()
        view.backgroundColor = Color.gray300
        view.contentMode = .scaleToFill
        view.layer.cornerRadius = 10
        view.clipsToBounds = true
        return view
    }()
    
    private let categoryLabel: UILabel = {
        let label = LabelWithPadding(topInset: 6, bottomInset: 6, leftInset: 12, rightInset: 12)
        label.font = Typo.Body4()
        label.textColor = .white
        label.backgroundColor = Color.purple400
        label.layer.cornerRadius = 4
        label.clipsToBounds = true
        return label
    }()

    private let nicknameLabel: UILabel = {
        LabelFactory.build(text: "", font: Typo.Body3(), textColor: Color.gray700)
    }()

    private lazy var vStack: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [imageView, nicknameLabel])
        stackView.axis = .vertical
        stackView.alignment = .leading
        stackView.spacing = 10
        return stackView
    }()
    
    override init(frame: CGRect) {
      super.init(frame: frame)
      setUI()
    }

    required init?(coder aDecoder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
    }
}

extension HouseGridCell {
    func configure(with house: HouseWithNickname) {
        imageView.kf.setImage(with: house.imageUrl)
        nicknameLabel.text = house.nickname
        categoryLabel.text = house.category
    }
    
    private func setUI() {
        [vStack, categoryLabel].forEach {
            addSubview($0)
        }
        
        imageView.snp.makeConstraints { make in
            make.width.height.equalTo(HouseGridCell.width)
        }
        
        vStack.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        categoryLabel.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().inset(12)
        }
    }
}
