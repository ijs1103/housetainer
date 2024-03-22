//
//  CarouselCell.swift
//  Housetainer
//
//  Created by 이주상 on 2023/11/15.
//

import UIKit
import SnapKit
import Kingfisher

final class CarouselCell: UICollectionViewCell {
        
    private let categoryLabel: UILabel = {
        let label = LabelWithPadding(topInset: 6, bottomInset: 6, leftInset: 12, rightInset: 12)
        label.font = Typo.Body6()
        label.textColor = Color.yellow300
        label.backgroundColor = Color.yellow100
        label.layer.cornerRadius = 4
        label.clipsToBounds = true
        return label
    }()
    
    private lazy var imageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleToFill
        view.layer.cornerRadius = 10
        view.clipsToBounds = true
        return view
    }()
    
    private let date: UILabel = {
        LabelFactory.build(text: "", font: Typo.Body5(), textColor: .white)
    }()
    
    private let titleLabel: UILabel = {
        let label = LabelFactory.build(text: "", font: Typo.Title2(), textColor: .white)
        label.numberOfLines = 2
        label.textAlignment = .left
        return label
    }()
    
    private lazy var vStack: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [date, titleLabel])
        stackView.axis = .vertical
        stackView.alignment = .leading
        stackView.spacing = 6
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

extension CarouselCell {
    func configure(_ event: Event) {
        imageView.kf.setImage(with: event.imageUrl)
        categoryLabel.text = "행사"
        date.text = event.date
        titleLabel.text = event.title
    }
    
    private func setUI() {
        [imageView, categoryLabel, vStack].forEach {
            addSubview($0)
        }
        
        imageView.snp.makeConstraints { make in
            make.width.equalTo(300)
            make.height.equalTo(200)
            make.edges.equalToSuperview()
        }
        
        categoryLabel.snp.makeConstraints { make in
            make.leading.top.equalToSuperview().inset(12)
        }
        
        vStack.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(12)
            make.bottom.equalToSuperview().offset(-10)
        }
    }
}
