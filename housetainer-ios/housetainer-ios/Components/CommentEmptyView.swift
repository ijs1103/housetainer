//
//  CommentEmptyView.swift
//  Housetainer
//
//  Created by 이주상 on 2023/11/28.
//

import UIKit
import SnapKit

final class CommentEmptyView: UIView {
    private let textLabel: UILabel = {
        let label = LabelFactory.build(text: Label.emptyComment, font: Typo.Body3(), textColor: Color.gray600)
        label.numberOfLines = 2
        return label
    }()
    
    init() {
        super.init(frame: .zero)
        setUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension CommentEmptyView {
    private func setUI() {
        
        addSubview(textLabel)
        
        textLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
