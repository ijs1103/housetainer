//
//  EventGridCell.swift
//  Housetainer
//
//  Created by 이주상 on 2023/11/18.
//

import UIKit
import SnapKit
import Kingfisher

final class EventGridCell: UICollectionViewCell {
    
    static let width: CGFloat = (UIScreen.main.bounds.width - 50.0) / 2
        
    private lazy var imageView: UIImageView = {
        let view = UIImageView()
        view.backgroundColor = Color.gray300
        view.contentMode = .scaleToFill
        view.layer.cornerRadius = 10
        view.clipsToBounds = true
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = LabelFactory.build(text: "", font: Typo.Body3())
        label.numberOfLines = 2
        label.textAlignment = .left
        return label
    }()
    
    private let nicknameLabel: UILabel = {
        LabelFactory.build(text: "", font: Typo.Body3(), textColor: Color.gray700)
    }()
    
    private let dateLabel: UILabel = {
        LabelFactory.build(text: "", font: Typo.Body5(), textColor: Color.gray500)
    }()
    
    private lazy var vStack: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [imageView, titleLabel, nicknameLabel, dateLabel])
        stackView.setCustomSpacing(10, after: imageView)
        stackView.setCustomSpacing(8, after: nicknameLabel)
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

extension EventGridCell {
    func configure(with event: EventWithNickname) {
        imageView.kf.setImage(with: event.imageUrl)
        nicknameLabel.text = event.nickname
        dateLabel.text = event.date
        titleLabel.text = event.title
    }
    
    private func setUI() {
        [vStack].forEach {
            addSubview($0)
        }
        
        imageView.snp.makeConstraints { make in
            make.width.height.equalTo(EventGridCell.width)
        }
        
        vStack.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
