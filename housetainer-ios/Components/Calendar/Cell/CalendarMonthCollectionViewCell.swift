//
//  CalendarMonthCollectionViewCell.swift
//  housetainer-ios
//
//  Created by 김수아 on 1/10/24.
//

import Foundation
import UIKit
import SnapKit

final class CalendarMonthCollectionViewCell: UICollectionViewCell{
    var didTapDay: ((DayOfMonth) -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update(with item: Item, selectedDay: DayOfMonth?){
        calendarMonthView.month = item.month
        calendarMonthView.selectedDay = selectedDay
    }
    
    // MARK: - Private
    private var item: Item?
    
    // MARK: - UI Properties
    private let calendarMonthView = CalendarMonthView()
}

private extension CalendarMonthCollectionViewCell{
    func setupUI(){
        contentView.layoutMargins = .zero
        contentView.addSubview(calendarMonthView)
        
        calendarMonthView.didTap = { [weak self] item in
            guard let self, case let .day(dayItem) = item, let day = dayItem.day else{ return }
            didTapDay?(day)
        }
        
        calendarMonthView.snp.makeConstraints{
            $0.directionalEdges.equalTo(contentView.snp.directionalMargins)
        }
    }
}

extension CalendarMonthCollectionViewCell{
    struct Item: Equatable{
        let month: MonthOfYear
    }
}
