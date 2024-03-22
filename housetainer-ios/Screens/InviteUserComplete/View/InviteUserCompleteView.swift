//
//  InviteUserCompleteView.swift
//  housetainer-ios
//
//  Created by 김수아 on 2/12/24.
//

import Foundation
import UIKit
import SwiftUI
import SnapKit

final class InviteUserCompleteView: UIView{
    var didTapClose: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        define()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layout()
    }
    
    // MARK: - UI Properties
    private lazy var closeButton = {
        let button = UIButton()
        button.setImage(Icon.close, for: .normal)
        button.addTarget(self, action: #selector(didTapCloseAction), for: .touchUpInside)
        return button
    }()
    private let imageView = {
        let imageView = UIImageView()
        imageView.image = Image.sendEMail
        return imageView
    }()
    private let titleLabel = {
        let label = UILabel()
        label.font = Typo.Title4()
        label.textColor = Color.black
        label.text = """
        초대 이메일을
        발송하였습니다
        """
        label.numberOfLines = 0
        return label
    }()
    
    // MARK: - Private
}

private extension InviteUserCompleteView{
    func setupUI(){
        backgroundColor = Color.white
        
        addSubview(closeButton)
        addSubview(imageView)
        addSubview(titleLabel)
    }
    
    func define(){
        closeButton.snp.makeConstraints{
            $0.top.equalTo(safeAreaLayoutGuide.snp.top).inset(12)
            $0.trailing.equalToSuperview().inset(20)
        }
        
        imageView.snp.makeConstraints{
            $0.top.greaterThanOrEqualToSuperview()
            $0.leading.greaterThanOrEqualToSuperview()
            $0.trailing.lessThanOrEqualToSuperview()
            $0.centerX.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints{
            $0.top.equalTo(imageView.snp.bottom).offset(11)
            $0.leading.greaterThanOrEqualToSuperview()
            $0.trailing.lessThanOrEqualToSuperview()
            $0.centerX.equalToSuperview()
            $0.bottom.lessThanOrEqualToSuperview().inset(245)
        }
    }
    
    func layout(){
        
    }
    
    @objc func didTapCloseAction(){
        didTapClose?()
    }
}

struct InviteUserCompleteView_Preview: PreviewProvider{
    static var previews: some View{
        ViewPreview{
            let view = InviteUserCompleteView()
            return view
        }
    }
}
