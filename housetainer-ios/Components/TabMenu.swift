//
//  TabMenu.swift
//  Housetainer
//
//  Created by 이주상 on 2023/11/15.
//

import UIKit
import SnapKit

enum CurrentTab {
    case socialCalendar, openHouse
}

protocol TabMenuDelegate: AnyObject {
    func didTapCalendar()
    func didTapHouse()
}

final class TabMenu: UIView {
    
    weak var delegate: TabMenuDelegate?
    var currentTab: CurrentTab = .socialCalendar
    
    private let calendarLabel: UILabel = {
        LabelFactory.build(text: Title.socialCalendar, font: Typo.Title1())
    }()
    
    private let cBottomBorder: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.heightAnchor.constraint(equalToConstant: 4).isActive = true
        return view
    }()
    
    private let houseLabel: UILabel = {
        LabelFactory.build(text: Title.openHouse, font: Typo.Title1(), textColor: Color.gray400)
    }()
    
    private let hBottomBorder: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.heightAnchor.constraint(equalToConstant: 4).isActive = true
        return view
    }()
    
    private lazy var calendarStack: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [calendarLabel, cBottomBorder])
        stackView.axis = .vertical
        stackView.spacing = 12
        let tgr = UITapGestureRecognizer(target: self, action: #selector(didTapCalendar))
        stackView.addGestureRecognizer(tgr)
        stackView.isUserInteractionEnabled = true
        return stackView
    }()
    
    private lazy var houseStack: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [houseLabel, hBottomBorder])
        stackView.axis = .vertical
        stackView.spacing = 12
        let tgr = UITapGestureRecognizer(target: self, action: #selector(didTapHouse))
        stackView.addGestureRecognizer(tgr)
        stackView.isUserInteractionEnabled = true
        return stackView
    }()
    
    private lazy var hStack: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [calendarStack, houseStack])
        stackView.axis = .horizontal
        stackView.spacing = 20
        return stackView
    }()
    
    init() {
        super.init(frame: .zero)
        setUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension TabMenu {
    private func setUI() {
        [hStack].forEach {
            addSubview($0)
        }
        
        hStack.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    @objc private func didTapCalendar() {
        UIView.animate(withDuration: 0.2) { [weak self] in
            guard let self = self else { return }
            calendarLabel.textColor = .black
            cBottomBorder.backgroundColor = .black
            houseLabel.textColor = Color.gray400
            hBottomBorder.backgroundColor = .clear
        }
        delegate?.didTapCalendar()
    }
    
    @objc private func didTapHouse() {
        didTapHouseHandler()
    }
    
    func didTapHouseHandler() {
        UIView.animate(withDuration: 0.2) { [weak self] in
            guard let self = self else { return }
            calendarLabel.textColor = Color.gray400
            cBottomBorder.backgroundColor = .clear
            houseLabel.textColor = .black
            hBottomBorder.backgroundColor = .black
        }
        delegate?.didTapHouse()
    }
}
