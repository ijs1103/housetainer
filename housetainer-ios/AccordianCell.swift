//
//  AccordianCell.swift
//  housetainer-ios
//
//  Created by 이주상 on 2023/11/30.
//

import UIKit
import SnapKit

final class AccordianCell: UIView {
    
    private lazy var avatar: UIImageView = {
        let view = UIImageView(image: Icon.nofaceXS)
        view.contentMode = .scaleToFill
        view.heightAnchor.constraint(equalToConstant: 36).isActive = true
        view.widthAnchor.constraint(equalToConstant: 36).isActive = true
        view.layer.cornerRadius = 18
        view.layer.masksToBounds = true
        return view
    }()
    
    private let nickname: UILabel = {
        LabelFactory.build(text: "", font: Typo.Body3(), textColor: Color.gray700)
    }()
    
    private lazy var housetainerIcon: UIImageView = {
        UIImageView(image: Icon.housetainer)
    }()
    
    private lazy var hStack: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [avatar, nickname])
        stackView.axis = .horizontal
        stackView.spacing = 4
        return stackView
    }()
    
    init(isHouseTainer: Bool = false) {
        super.init(frame: .zero)
        if isHouseTainer {
            hStack.addArrangedSubview(housetainerIcon)
        }
        nickname.text = "오버쿡드"
        setUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension AccordianCell {

    private func setUI() {
        backgroundColor = Color.gray100

        [hStack].forEach {
            addSubview($0)
        }

        hStack.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(16)
            make.top.bottom.equalToSuperview()
        }
    }
}
