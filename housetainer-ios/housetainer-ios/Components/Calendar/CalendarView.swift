//
//  CalendarView.swift
//  housetainer-ios
//
//  Created by 김수아 on 1/9/24.
//

import Foundation
import UIKit
import SnapKit
import SwiftUI

final class CalendarView: UIView{
    var didTapDay: ((DayOfMonth) -> Void)?
    var months: [MonthOfYear] = []{
        didSet{
            guard oldValue != months else{ return }
            currentIndexPath = .zero
            items = months.map{ Item(month: $0 ) }
            titleLabel.text = dateFormatter.string(from: items[currentIndexPath.item].month._storage)
        }
    }
    
    override var intrinsicContentSize: CGSize{
        CGSize(width: UIView.noIntrinsicMetric, height: 263)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI Properties
    private let titleContainer = UIView()
    private lazy var previousImageView = {
        let imageView = UIImageView()
        imageView.image = Icon.calendarArrowLeft
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapPrevious(_:))))
        return imageView
    }()
    private let titleLabel = {
        let label = UILabel()
        label.font = Typo.Title2()
        label.textColor = Color.black
        label.numberOfLines = 1
        return label
    }()
    private lazy var nextImageView = {
        let imageView = UIImageView()
        imageView.image = Icon.calendarArrowRight
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapNext(_:))))
        return imageView
    }()
    
    private lazy var collectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: {
            let layout = UICollectionViewFlowLayout()
            layout.scrollDirection = .horizontal
            return layout
        }())
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.isPagingEnabled = true
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.backgroundColor = .clear
        collectionView.contentInset = .zero
        collectionView.register(CalendarMonthCollectionViewCell.self, forCellWithReuseIdentifier: String(describing: CalendarMonthCollectionViewCell.self))
        return collectionView
    }()
    
    func previousMonth(){
        guard !collectionView.isDecelerating, currentIndexPath.item > 0 else{ return }
        let indexPath = IndexPath(item: currentIndexPath.item - 1, section: 0)
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        currentIndexPath = indexPath
    }
    
    func nextMonth(){
        guard !collectionView.isDecelerating, currentIndexPath.item < items.count - 1 else{ return }
        let indexPath = IndexPath(item: currentIndexPath.item + 1, section: 0)
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        currentIndexPath = indexPath
    }
    
    // MARK: - Private
    private let dateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy년 M월"
        dateFormatter.locale = Locale.current
        dateFormatter.timeZone = TimeZone(identifier: "UTC")
        return dateFormatter
    }()
    private var currentIndexPath: IndexPath = .zero{
        didSet{
            guard !items.isEmpty else{ return }
            titleLabel.text = dateFormatter.string(from: items[currentIndexPath.item].month._storage)
        }
    }
    private var items: [Item] = [] {
        didSet{
            guard oldValue != items else{ return }
            collectionView.reloadData()
        }
    }
    private var selectedDay: DayOfMonth = DayOfMonth()
}

private extension CalendarView{
    func setupUI(){
        addSubview(titleContainer)
        titleContainer.addSubview(previousImageView)
        titleContainer.addSubview(titleLabel)
        titleContainer.addSubview(nextImageView)
        addSubview(collectionView)
        
        titleContainer.snp.makeConstraints{
            $0.top.equalToSuperview()
            $0.directionalHorizontalEdges.equalToSuperview()
        }
        previousImageView.snp.makeConstraints{
            $0.leading.equalToSuperview().inset(20)
            $0.top.greaterThanOrEqualToSuperview()
            $0.bottom.lessThanOrEqualToSuperview()
            $0.centerY.equalToSuperview()
        }
        nextImageView.snp.makeConstraints{
            $0.trailing.equalToSuperview().inset(20)
            $0.top.greaterThanOrEqualToSuperview()
            $0.bottom.lessThanOrEqualToSuperview()
            $0.centerY.equalToSuperview()
        }
        titleLabel.snp.makeConstraints{
            $0.leading.greaterThanOrEqualTo(previousImageView.snp.trailing)
            $0.trailing.greaterThanOrEqualTo(previousImageView.snp.leading)
            $0.center.equalToSuperview()
            $0.top.greaterThanOrEqualToSuperview()
            $0.bottom.lessThanOrEqualToSuperview()
        }
        collectionView.snp.makeConstraints{
            $0.top.equalTo(titleContainer.snp.bottom)
            $0.bottom.directionalHorizontalEdges.equalTo(safeAreaLayoutGuide)
            $0.height.equalTo(30 * 6)
        }
    }
    
    @objc func didTapPrevious(_ recognizer: UITapGestureRecognizer){
        previousMonth()
    }
    
    @objc func didTapNext(_ recognizer: UITapGestureRecognizer){
        nextMonth()
    }
}

extension CalendarView: UIScrollViewDelegate{
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let currentIndex = Int(ceil(scrollView.contentOffset.x / scrollView.bounds.width))
        guard currentIndex < items.count - 1 else{ return }
        currentIndexPath = IndexPath(item: currentIndex, section: 0)
    }
}

extension CalendarView: UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        .zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.bounds.size
    }
}

extension CalendarView: UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: CalendarMonthCollectionViewCell.self), for: indexPath) as? CalendarMonthCollectionViewCell else{ return UICollectionViewCell() }
        cell.update(with: items[indexPath.item], selectedDay: selectedDay)
        cell.didTapDay = { [weak self] day in
            guard let self else{ return }
            selectedDay = day
            collectionView.reloadData()
            
            didTapDay?(day)
        }
        return cell
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        items.count
    }
}

extension CalendarView{
    typealias Item = CalendarMonthCollectionViewCell.Item
}

struct CalendarView_Preview: PreviewProvider{
    static var previews: some View{
        VStack{
            ViewPreview{
                let calendarView = CalendarView()
                calendarView.months = (0...12).map{
                    var month = MonthOfYear()
                    month.month += $0
                    return month
                }
                return calendarView
            }
        }
    }
}
