//
//  WarningView.swift
//  housetainer-ios
//
//  Created by 이주상 on 4/2/24.
//

import UIKit
import SnapKit

final class WarningView: UIView {

    private let warningImage = UIImageView(image: Icon.warning)

    private let titleLabel: UILabel = {
        LabelFactory.build(text: Title.warning, font: Typo.Body3(), textColor: UIColor(red: 1.00, green: 0.45, blue: 0.45, alpha: 1.00))
    }()
    
    private lazy var hStack: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [warningImage, titleLabel])
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

extension WarningView {
    private func setUI() {
        backgroundColor = UIColor(red: 1.00, green: 0.95, blue: 0.95, alpha: 1.00)
        layer.cornerRadius = 4
        clipsToBounds = true
        
        addSubview(hStack)
        
        hStack.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.bottom.equalToSuperview().offset(-8)
            make.centerX.equalToSuperview()
        }
    }
}

