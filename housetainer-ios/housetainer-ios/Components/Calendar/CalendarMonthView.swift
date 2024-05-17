//
//  CalendarMonthView.swift
//  housetainer-ios
//
//  Created by 김수아 on 1/10/24.
//

import Foundation
import UIKit
import SnapKit
import SwiftUI

final class CalendarMonthView: UIView{
    var didTap: ((Item) -> Void)?
    var selectedDay: DayOfMonth?{
        didSet{
            guard oldValue != selectedDay else{ return }
            update(with: month, selectedDay: selectedDay)
        }
    }
    var month: MonthOfYear = .init(){
        didSet{
            guard oldValue != month else{ return }
            update(with: month, selectedDay: selectedDay)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        update(with: month, selectedDay: selectedDay)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI Properties
    private lazy var collectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: {
            let layout = UICollectionViewFlowLayout()
            layout.scrollDirection = .vertical
            return layout
        }())
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .clear
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        collectionView.register(CalendarDayCollectionViewCell.self, forCellWithReuseIdentifier: String(describing: CalendarDayCollectionViewCell.self))
        collectionView.register(CalendarWeekDayCollectionViewCell.self, forCellWithReuseIdentifier: String(describing: CalendarWeekDayCollectionViewCell.self))
        return collectionView
    }()
    
    // MARK: - Private
    private var items: [Item] = [] {
        didSet{
            collectionView.reloadData()
        }
    }
}

private extension CalendarMonthView{
    func setupUI(){
        layoutMargins = .zero
        addSubview(collectionView)
        
        collectionView.snp.makeConstraints{
            $0.directionalEdges.equalTo(self.snp.directionalMargins)
        }
    }
    
    func update(with month: MonthOfYear, selectedDay: DayOfMonth?){
        let calendar = Calendar.gmt
        guard
            let startDayOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: month._storage)),
            let endDayOfMonth = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: startDayOfMonth)
        else{ return }
        
        let days = (DayOfMonth(startDayOfMonth)...DayOfMonth(endDayOfMonth)).map{ $0 }
        let leadingDays: [DayOfMonth?] = (0..<(DayOfMonth(startDayOfMonth).week - 1)).map{ _ in nil }
        let currentDay = calendar.date(bySettingHour: 0, minute: 0, second: 0, of: Date()) ?? month._storage
//        let currentDay = calendar.date(byAdding: .second, value: TimeZone.current.secondsFromGMT(for: Date()), to: calendar.startOfDay(for: Date())) ?? calendar.startOfDay(for: Date())
        self.items = calendar.shortWeekdaySymbols.map{
            .weekday(CalendarWeekDayCollectionViewCell.Item(title: $0))
        } + (leadingDays + days).map{
            .day(CalendarDayCollectionViewCell.Item(day: $0, isEnabled: currentDay <= ($0?._storage ?? month._storage)))
        }
        
        if let selectedDay, let item = items.firstIndex(of: .day(.init(day: selectedDay, isEnabled: true))){
            collectionView.selectItem(at: IndexPath(item: item, section: 0), animated: false, scrollPosition: .centeredHorizontally)
        }
    }
}

extension CalendarMonthView: UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        .zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        let width = collectionView.bounds.width - collectionView.adjustedContentInset.left - collectionView.adjustedContentInset.right - 30 * 7
        return floor(width / 6)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 30, height: 30)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = items[indexPath.item]
        didTap?(item)
    }
}

extension CalendarMonthView: UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch items[indexPath.item]{
        case let .day(item):
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: CalendarDayCollectionViewCell.self), for: indexPath) as? CalendarDayCollectionViewCell else{ return UICollectionViewCell() }
            cell.update(with: item)
            return cell
        case let .weekday(item):
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: CalendarWeekDayCollectionViewCell.self), for: indexPath) as? CalendarWeekDayCollectionViewCell else{ return UICollectionViewCell() }
            cell.update(with: item)
            return cell
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        items.count
    }
}

extension CalendarMonthView{
    enum Item: Equatable{
        case weekday(CalendarWeekDayCollectionViewCell.Item)
        case day(CalendarDayCollectionViewCell.Item)
    }
}

struct CalendarMonthView_Preview: PreviewProvider{
    static var previews: some View{
        Group{
            ViewPreview{
                let calendarView = CalendarMonthView()
                return calendarView
            }
        }
    }
}
