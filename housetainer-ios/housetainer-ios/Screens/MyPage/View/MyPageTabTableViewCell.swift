//
//  MyPageTabTableViewCell.swift
//  housetainer-ios
//
//  Created by 김수아 on 1/7/24.
//

import Foundation
import UIKit
import SwiftUI
import SnapKit

final class MyPageTabTableViewCell: UITableViewCell{
    var didTapItem: ((Tab) -> Void)?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update(with selectedTab: Tab){
        self.selectedTab = selectedTab
        imakeButton.isSelected = selectedTab == .iMake
        ipickButton.isSelected = selectedTab == .iPick
        setNeedsUpdateConstraints()
    }
    
    override func updateConstraints() {
        stackView.snp.updateConstraints{
            $0.top.equalToSuperview().inset(4)
            $0.leading.equalToSuperview().inset(20)
            $0.trailing.lessThanOrEqualToSuperview().inset(20)
            $0.bottom.equalToSuperview()
            $0.height.equalTo(27)
        }
        
        super.updateConstraints()
    }
    
    // MARK: - Private
    private var selectedTab: Tab = .iMake
    
    // MARK: - UI Properties
    private let stackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 20
        return stackView
    }()
    private lazy var imakeButton = {
        let button = UIButton()
        button.titleLabel?.font = Typo.Body2Semibold()
        button.setTitle("i_make", for: .normal)
        button.setTitleColor(Color.gray400, for: .normal)
        button.setTitleColor(Color.reddishPurple500, for: .selected)
        button.addTarget(self, action: #selector(didTapButton), for: .touchUpInside)
        return button
    }()
    private lazy var ipickButton = {
        let button = UIButton()
        button.titleLabel?.font = Typo.Body2Semibold()
        button.setTitle("i_pick", for: .normal)
        button.setTitleColor(Color.gray400, for: .normal)
        button.setTitleColor(Color.reddishPurple500, for: .selected)
        button.addTarget(self, action: #selector(didTapButton), for: .touchUpInside)
        return button
    }()
}

extension MyPageTabTableViewCell{
    enum Tab{
        case iMake
        case iPick
    }
}

private extension MyPageTabTableViewCell{
    func setupUI(){
        contentView.backgroundColor = .white
        selectionStyle = .none
        contentView.addSubview(stackView)
        stackView.addArrangedSubview(imakeButton)
        stackView.addArrangedSubview(ipickButton)
    }
    
    @objc func didTapButton(_ button: UIButton){
        if imakeButton === button{
            didTapItem?(.iMake)
        }
        if ipickButton === button{
            didTapItem?(.iPick)
        }
    }
}

struct MyPageTabTableViewCell_Previews: PreviewProvider{
    static var previews: some View{
        ViewPreview{
            let cell = MyPageTabTableViewCell()
            cell.update(with: .iMake)
            return cell
        }
    }
}



