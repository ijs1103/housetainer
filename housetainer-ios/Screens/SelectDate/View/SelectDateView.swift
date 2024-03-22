//
//  SelectDateView.swift
//  housetainer-ios
//
//  Created by 김수아 on 2/17/24.
//

import Foundation
import UIKit
import SwiftUI
import SnapKit

final class SelectDateView: UIView{
    var didTapClose: ((Date?) -> Void)?
    var didTapDim: (() -> Void)?
    
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
    private lazy var dimArea = {
        let view = UIView()
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapDimAction)))
        return view
    }()
    private let contentContainer = {
        let view = UIView()
        view.backgroundColor = Color.white
        view.layer.cornerRadius = 16
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        return view
    }()
    private let titleLabel = {
        let label = UILabel()
        label.font = Typo.Title3()
        label.textColor = Color.black
        label.text = "날짜 선택"
        return label
    }()
    private lazy var closeButton = {
        let button = UIButton()
        button.setImage(Icon.close, for: .normal)
        button.addTarget(self, action: #selector(didTapCloseAction), for: .touchUpInside)
        return button
    }()
    private lazy var calendar = {
        let calendar = CalendarView()
        calendar.months = (0...12).map{
            var month = MonthOfYear()
            month.month += $0
            return month
        }
        calendar.didTapDay = { [weak self] day in
            guard let self else{ return }
            selectedDay = day
        }
        return calendar
    }()
    
    // MARK: - Private
    private var selectedDay: DayOfMonth?
}

private extension SelectDateView{
    func setupUI(){
        addSubview(dimArea)
        addSubview(contentContainer)
        contentContainer.addSubview(titleLabel)
        contentContainer.addSubview(closeButton)
        contentContainer.addSubview(calendar)
        
        backgroundColor = .black.withAlphaComponent(0.4)
    }
    
    func define(){
        dimArea.snp.makeConstraints{
            $0.directionalHorizontalEdges.top.equalToSuperview()
            $0.bottom.equalTo(contentContainer.snp.top)
        }
        contentContainer.snp.makeConstraints{
            $0.directionalHorizontalEdges.bottom.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints{
            $0.leading.equalToSuperview().inset(20)
            $0.top.equalToSuperview().inset(21)
            $0.trailing.lessThanOrEqualTo(closeButton.snp.leading)
        }
        
        closeButton.snp.makeConstraints{
            $0.centerY.equalTo(titleLabel.snp.centerY)
            $0.trailing.equalToSuperview().inset(20)
        }
        
        calendar.snp.makeConstraints{
            $0.top.equalTo(titleLabel.snp.bottom).offset(44)
            $0.directionalHorizontalEdges.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
    }
    
    func layout(){
        
    }
    
    @objc func didTapDimAction(){
        didTapDim?()
    }
    
    @objc func didTapCloseAction(){
        didTapClose?(selectedDay?.date)
    }
}

struct SelectDateView_Previews: PreviewProvider{
    static var previews: some View{
        ViewPreview{
            let view = SelectDateView()
            return view
        }
    }
}
