//
//  AccordianContents.swift
//  housetainer-ios
//
//  Created by 이주상 on 2023/12/03.
//

import UIKit
import SnapKit

final class AccordianContents: UIView {
    
    private let data: [AccordianCell]
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: data)
        stackView.axis = .vertical
        stackView.spacing = 12
        return stackView
    }()
    
    init(data: [AccordianCell]) {
        self.data = data
        super.init(frame: .zero)
        setUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension AccordianContents {
    private func setUI() {
        [stackView].forEach {
            addSubview($0)
        }
        
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        alpha = 0.0
    }
}
