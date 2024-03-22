//
//  AccordianHeader.swift
//  housetainer-ios
//
//  Created by 이주상 on 2023/12/02.
//

import UIKit
import SnapKit

final class AccordianHeader: UIView {
    
    private let title: UILabel = {
        LabelFactory.build(text: Title.socialMember, font: Typo.Title4(), textColor: Color.gray700)
    }()
    
    private lazy var chevron: UIImageView = {
        let view = UIImageView(image: Icon.arrowDown)
        view.contentMode = .scaleAspectFit
        return view
    }()
    
    private lazy var hStack: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [title, chevron])
        stackView.axis = .horizontal
        stackView.spacing = 4
        return stackView
    }()
    
    init() {
        super.init(frame: .zero)
        setUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension AccordianHeader {
    func toggleArrowImage(isAccordianActive: Bool) {
        chevron.image = isAccordianActive ? Icon.arrowUp : Icon.arrowDown
    }
    
    private func setUI() {
        backgroundColor = Color.gray100

        [hStack].forEach {
            addSubview($0)
        }

        hStack.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(16)
            make.top.equalToSuperview().inset(16)
            make.bottom.equalToSuperview()
        }
    }
}
