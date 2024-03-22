//
//  CtaButton.swift
//  Housetainer
//
//  Created by 이주상 on 2023/11/10.
//

import UIKit
import SnapKit

protocol CtaButtonDelegate: AnyObject {
    func didTapCtaButton(title: String)
}

final class CtaButton: UIView {
    weak var delegate: CtaButtonDelegate?
    
    private let titleLabel: UILabel = {
        LabelFactory.build(text: "", font: Typo.Body3(), textColor: Color.gray600)
    }()
    
    private lazy var chevronRight: UIImageView = {
        let view = UIImageView(image: Icon.arrowRight)
        view.contentMode = .scaleAspectFit
        return view
    }()
    
    private lazy var hStack: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [titleLabel, chevronRight])
        stackView.axis = .horizontal
        stackView.spacing = 6.8
        stackView.layer.cornerRadius = 4
        stackView.backgroundColor = Color.gray100
        // stack padding
        stackView.layoutMargins = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
        stackView.isLayoutMarginsRelativeArrangement = true
        return stackView
    }()
    
    init(title: String) {
        super.init(frame: .zero)
        self.titleLabel.text = title
        setUI()
        setGesture()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension CtaButton {
    private func setUI() {
        
        [hStack].forEach {
            addSubview($0)
        }
        
        hStack.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func setGesture() {
        let tgr = UITapGestureRecognizer(target: self, action: #selector(didTapCtaButton))
        addGestureRecognizer(tgr)
    }
    
    @objc private func didTapCtaButton() {
        delegate?.didTapCtaButton(title: self.titleLabel.text!)
    }
}
