//
//  MyPageSectionHeaderTableViewCell.swift
//  housetainer-ios
//
//  Created by 김수아 on 1/2/24.
//

import Foundation
import UIKit
import SwiftUI
import SnapKit

final class MyPageSectionHeaderTableViewCell: UIView{
    
    override init(frame: CGRect){
        super.init(frame: frame)
        setupUI()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        for layer in tooltipContainer.layer.sublayers ?? []{
            layer.contentsScale = tooltipContainer.window?.screen.scale ?? 1
            layer.frame = tooltipContainer.layer.bounds
        }
    }
    
    func update(withTitle title: String, tooltip: String?){
        titleLabel.text = title
        tooltipLabel.text = tooltip
        tooltipContainer.layoutMargins = tooltip == nil ? .zero : UIEdgeInsets(top: 4, left: 16, bottom: 6, right: 16)
        
        setNeedsUpdateConstraints()
    }
    
    override func updateConstraints() {
        titleLabel.snp.updateConstraints{
            $0.top.equalToSuperview().inset(32)
            $0.leading.equalToSuperview().inset(20)
            $0.trailing.lessThanOrEqualToSuperview().inset(20)
            $0.bottom.equalToSuperview().priority(.medium)
        }
        
        tooltipContainer.snp.remakeConstraints{
            if tooltipLabel.text != nil{
                $0.top.equalTo(titleLabel.snp.bottom).offset(4)
                $0.leading.equalTo(titleLabel.snp.leading)
                $0.trailing.lessThanOrEqualToSuperview().inset(20)
                $0.bottom.equalToSuperview()
            }
        }
        
        tooltipLabel.snp.updateConstraints{
            $0.directionalEdges.equalTo(tooltipContainer.snp.directionalMargins)
        }
        super.updateConstraints()
    }
    
    // MARK: - UI Properties
    private let titleLabel = {
        let label = UILabel()
        label.font = Typo.Body1SemiBold()
        label.textColor = Color.gray800
        label.numberOfLines = 0
        return label
    }()
    
    private let tooltipContainer = {
        let view = UIView()
        view.layoutMargins = UIEdgeInsets(top: 4, left: 8, bottom: 4, right: 8)
        view.layer.addSublayer({
            let sublayer = TooltipBackgroundLayer()
            sublayer.fillColor = Color.reddishPurple100
            return sublayer
        }())
        return view
    }()
    private let tooltipLabel = {
        let label = UILabel()
        label.font = Typo.Body3()
        label.textColor = Color.reddishPurple400
        label.numberOfLines = 0
        return label
    }()
    
    // MARK: - Private
}

private extension MyPageSectionHeaderTableViewCell{
    func setupUI(){
        addSubview(titleLabel)
        addSubview(tooltipContainer)
        tooltipContainer.addSubview(tooltipLabel)
    }
}

struct MyPageSectionHeaderTableViewCell_Previews: PreviewProvider{
    static var previews: some View{
        ViewPreview{
            let cell = MyPageSectionHeaderTableViewCell()
            cell.update(withTitle: """
            신체장애자 및 질병·노령 기타의 사유로 생활능력이 없는 국민은 법률이 정하는 바에 의하여 국가의 보호를 받는다. 국회가 재적의원 과반수의 찬성으로 계엄의 해제를 요구한 때에는 대통령은 이를 해제하여야 한다.
            
            모든 국민은 직업선택의 자유를 가진다. 대통령은 국가의 안위에 관계되는 중대한 교전상태에 있어서 국가를 보위하기 위하여 긴급한 조치가 필요하고 국회의 집회가 불가능한 때에 한하여 법률의 효력을 가지는 명령을 발할 수 있다.
            """, tooltip: """
            신체장애자 및 질병·노령 기타의 사유로 생활능력이 없는 국민은 법률이 정하는 바에 의하여 국가의 보호를 받는다. 국회가 재적의원 과반수의 찬성으로 계엄의 해제를 요구한 때에는 대통령은 이를 해제하여야 한다.
            
            모든 국민은 직업선택의 자유를 가진다. 대통령은 국가의 안위에 관계되는 중대한 교전상태에 있어서 국가를 보위하기 위하여 긴급한 조치가 필요하고 국회의 집회가 불가능한 때에 한하여 법률의 효력을 가지는 명령을 발할 수 있다.
            """)
            return cell
        }
    }
}

