//
//  AlertView.swift
//  housetainer-ios
//
//  Created by 김수아 on 4/14/24.
//

import Foundation
import UIKit
import SnapKit

final class AlertView: UIView{
    var title: String = ""{
        didSet{
            titleLabel.text = title
        }
    }
    var subtitle: String = ""{
        didSet{
            subtitleLabel.text = subtitle
        }
    }
    var negativeTitle: String = ""{
        didSet{
            negativeButton.setTitle(negativeTitle, for: .normal)
        }
    }
    var positiveTitle: String = ""{
        didSet{
            positiveButton.setTitle(positiveTitle, for: .normal)
        }
    }
    var didTapBackground: (() -> Void)?
    var didTapNegativeButton: (() -> Void)?
    var didTapPositiveButton: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func updateConstraints() {
        dimView.snp.updateConstraints{
            $0.directionalEdges.equalToSuperview()
        }
        
        alertContainer.snp.updateConstraints{
            $0.center.equalToSuperview()
            $0.top.leading.greaterThanOrEqualToSuperview()
            $0.bottom.trailing.lessThanOrEqualToSuperview()
        }
        
        titleLabel.snp.updateConstraints{
            $0.top.equalTo(alertContainer.snp.topMargin)
            $0.centerX.equalToSuperview()
            $0.leading.greaterThanOrEqualTo(alertContainer.snp.leadingMargin)
            $0.trailing.lessThanOrEqualTo(alertContainer.snp.trailingMargin)
        }
        
        subtitleLabel.snp.updateConstraints{
            $0.top.equalTo(titleLabel.snp.bottom).offset(12)
            $0.centerX.equalToSuperview()
            $0.leading.greaterThanOrEqualTo(alertContainer.snp.leadingMargin)
            $0.trailing.lessThanOrEqualTo(alertContainer.snp.trailingMargin)
        }
        
        buttonContainer.snp.updateConstraints{
            $0.top.equalTo(subtitleLabel.snp.bottom).offset(28)
            $0.leading.equalTo(alertContainer.snp.leadingMargin)
            $0.trailing.equalTo(alertContainer.snp.trailingMargin)
            $0.bottom.equalTo(alertContainer.snp.bottomMargin)
            $0.height.equalTo(51)
        }
        
        super.updateConstraints()
    }
    
    // MARK: - UI Properties
    private lazy var dimView = {
        let view = UIView()
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer({
            let gesture = UITapGestureRecognizer(target: self, action: #selector(didTapBackgroundAction))
            gesture.cancelsTouchesInView = true
            return gesture
        }())
        return view
    }()
    
    private let alertContainer = {
        let view = UIView()
        view.backgroundColor = Color.white
        view.layer.cornerRadius = 20
        view.layer.masksToBounds = true
        view.layer.shadowColor = UIColor(rgb: 0x340623).cgColor
        view.layer.shadowOpacity = 0.2
        view.layer.shadowRadius = 2
        view.layer.shadowOffset = .zero
        return view
    }()
    
    private let titleLabel = {
        let label = UILabel()
        label.font = Typo.Heading2Semibold()
        label.textColor = Color.gray800
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    private let subtitleLabel = {
        let label = UILabel()
        label.font = Typo.Body2()
        label.textColor = Color.gray700
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    private let buttonContainer = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 12
        stackView.distribution = .fillEqually
        return stackView
    }()
    
    private lazy var negativeButton = {
        let button = UIButton()
        button.contentEdgeInsets = .init(top: 16, left: 32, bottom: 16, right: 32)
        button.titleLabel?.font = Typo.Body2Medium()
        button.setTitleColor(Color.white, for: .normal)
        button.setBackgroundColor(Color.reddishPurple500, for: .normal)
        button.layer.cornerRadius = 8
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(didTapNegativeButtonAction), for: .touchUpInside)
        return button
    }()
    
    private lazy var positiveButton = {
        let button = UIButton()
        button.contentEdgeInsets = .init(top: 16, left: 32, bottom: 16, right: 32)
        button.titleLabel?.font = Typo.Body2Medium()
        button.setTitleColor(Color.gray700, for: .normal)
        button.layer.borderWidth = 1
        button.layer.borderColor = Color.gray400.cgColor
        button.layer.cornerRadius = 8
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(didTapPositiveButtonAction), for: .touchUpInside)
        return button
    }()
}

private extension AlertView{
    func setupUI(){
        backgroundColor = Color.black.withAlphaComponent(0.65)
        
        addSubview(dimView)
        addSubview(alertContainer)
        alertContainer.layoutMargins = .init(top: 24, left: 24, bottom: 24, right: 24)
        alertContainer.addSubview(titleLabel)
        alertContainer.addSubview(subtitleLabel)
        alertContainer.addSubview(buttonContainer)
        buttonContainer.addArrangedSubview(negativeButton)
        buttonContainer.addArrangedSubview(positiveButton)

        setNeedsUpdateConstraints()
    }
    
    @objc func didTapBackgroundAction(){
        didTapBackground?()
    }
    
    @objc func didTapNegativeButtonAction(){
        didTapNegativeButton?()
    }
    
    @objc func didTapPositiveButtonAction(){
        didTapPositiveButton?()
    }
}
