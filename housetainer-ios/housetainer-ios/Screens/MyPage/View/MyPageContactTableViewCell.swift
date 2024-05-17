//
//  MyPageContactTableViewCell.swift
//  housetainer-ios
//
//  Created by 김수아 on 4/14/24.
//

import Foundation
import UIKit
import SwiftUI
import SnapKit

final class MyPageContactTableViewCell: UITableViewCell{
    var didTapContact: (() -> Void)?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update(){
        setNeedsUpdateConstraints()
    }
    
    override func updateConstraints() {
        topView.snp.updateConstraints{
            $0.top.equalToSuperview()
            $0.directionalHorizontalEdges.equalToSuperview()
            $0.height.equalTo(0.75)
        }
        
        contactButton.snp.updateConstraints{
            $0.directionalEdges.equalTo(contentView.snp.directionalMargins)
            $0.height.equalTo(51)
        }
        
        super.updateConstraints()
    }
    
    // MARK: - UI Properties
    private let topView = {
        let view = UIView()
        view.backgroundColor = Color.gray150
        return view
    }()
    
    private lazy var contactButton = {
        let button = UIButton()
        button.titleLabel?.font = Typo.Body2Medium()
        button.setTitle("문의하기", for: .normal)
        button.setTitleColor(Color.reddishPurple600, for: .normal)
        button.layer.borderWidth = 1
        button.layer.borderColor = Color.reddishPurple600.cgColor
        button.layer.cornerRadius = 8
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(didTapContactAction), for: .touchUpInside)
        return button
    }()
}

extension MyPageContactTableViewCell{
    enum Tab{
        case iMake
        case iPick
    }
}

private extension MyPageContactTableViewCell{
    func setupUI(){
        contentView.backgroundColor = .white
        selectionStyle = .none
        contentView.layoutMargins = UIEdgeInsets(top: 40, left: 20, bottom: 60, right: 20)
        contentView.addSubview(topView)
        contentView.addSubview(contactButton)
    }
    
    @objc func didTapContactAction(_ button: UIButton){
        didTapContact?()
    }
}

struct MyPageContactTableViewCell_Previews: PreviewProvider{
    static var previews: some View{
        ViewPreview{
            let cell = MyPageContactTableViewCell()
            return cell
        }
    }
}
