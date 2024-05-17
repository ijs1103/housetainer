//
//  RelatedLinkView.swift
//  housetainer-ios
//
//  Created by 이주상 on 3/28/24.
//

import UIKit
import SnapKit

protocol RelatedLinkViewDelegate: AnyObject {
    func didTapRelatedLink()
}

final class RelatedLinkView: UIView {
    weak var delegate: RelatedLinkViewDelegate?
    
    private let titleLabel = LabelFactory.build(text: "관련 링크", font: Typo.Body3(), textColor: Color.gray600, textAlignment: .left)
    
    private let urlLabel = LabelFactory.build(text: "", font: Typo.Body5(), textColor: Color.gray500, textAlignment: .left)
    
    private lazy var hStack: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [titleLabel, urlLabel])
        stackView.axis = .horizontal
        stackView.spacing = 20
        return stackView
    }()
    
    init() {
        super.init(frame: .zero)
        setUI()
        setGestureRecognizer()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension RelatedLinkView {
    
    func urlText() -> String? {
        urlLabel.text
    }
    
    func setUrl(_ urlText: String) {
        urlLabel.text = urlText
    }
    
    private func setUI() {
        backgroundColor = .clear
        layer.cornerRadius = 8
        layer.borderWidth = 1
        layer.borderColor = Color.gray150.cgColor

        [hStack].forEach {
            addSubview($0)
        }

        hStack.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(16)
            make.top.bottom.equalToSuperview().inset(16)
        }
    }
    
    private func setGestureRecognizer() {
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapRelatedLink))
        urlLabel.addGestureRecognizer(gestureRecognizer)
        urlLabel.isUserInteractionEnabled = true
    }
    
    @objc private func didTapRelatedLink() {
        delegate?.didTapRelatedLink()
    }
}
