//
//  MyPageCalendarTableViewCell.swift
//  housetainer-ios
//
//  Created by 김수아 on 1/3/24.
//

import Foundation
import UIKit
import SwiftUI
import SnapKit

final class MyPageCalendarTableViewCell: UITableViewCell{
    var didTapItem: ((MyPageCalendarCollectionViewCell.Item) -> Void)?
    var scrolledToLast: (() -> Void)?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update(with item: Item){
        self.items = item.calendars
        collectionView.reloadData()
    }
    
    // MARK: - UI Properties
    private lazy var collectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: {
            let layout = UICollectionViewFlowLayout()
            layout.scrollDirection = .horizontal
            return layout
        }())
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 20, bottom: 40, right: 20)
        collectionView.register(MyPageCalendarCollectionViewCell.self, forCellWithReuseIdentifier: String(describing: MyPageCalendarCollectionViewCell.self))
        collectionView.showsHorizontalScrollIndicator = false
        return collectionView
    }()
    
    private let calendarCell = MyPageCalendarCollectionViewCell()
    
    // MARK: - Private
    private var items: [MyPageCalendarCollectionViewCell.Item] = []
}

private extension MyPageCalendarTableViewCell{
    func setupUI(){
        selectionStyle = .none
        contentView.addSubview(collectionView)
        
        collectionView.snp.makeConstraints{
            $0.edges.equalToSuperview()
            $0.height.greaterThanOrEqualTo(268 + collectionView.contentInset.top + collectionView.contentInset.bottom)
        }
    }
    
    func cellWidth(_ collectionView: UICollectionView) -> CGFloat{
        collectionView.bounds.width - collectionView.contentInset.left - collectionView.contentInset.right - 35
    }
}

extension MyPageCalendarTableViewCell: UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let height = collectionView.bounds.height - collectionView.contentInset.top - collectionView.contentInset.bottom
        calendarCell.update(with: items[indexPath.row])
        calendarCell.updateWidth(cellWidth(collectionView))
        return calendarCell.systemLayoutSizeFitting(CGSize(width: UIView.layoutFittingCompressedSize.width, height: height))
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.item == max(0, items.count - 1){
            scrolledToLast?()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = items[indexPath.item]
        didTapItem?(item)
    }
}

extension MyPageCalendarTableViewCell: UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: MyPageCalendarCollectionViewCell.self), for: indexPath) as? MyPageCalendarCollectionViewCell else{
            return UICollectionViewCell()
        }
        cell.update(with: items[indexPath.row])
        cell.updateWidth(cellWidth(collectionView))
        return cell
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        items.count
    }
}

extension MyPageCalendarTableViewCell{
    struct Item{
        let calendars: [MyPageCalendarCollectionViewCell.Item]
    }
}

struct MyPageCalendarTableViewCell_Previews: PreviewProvider{
    static var previews: some View{
        ViewPreview{
            MyPageCalendarTableViewCell()
        }
    }
}


