//
//  MyPageIPickSocialCalendarTableViewCell.swift
//  housetainer-ios
//
//  Created by 김수아 on 1/3/24.
//

import Foundation
import UIKit
import SwiftUI
import SnapKit

final class MyPageIPickSocialCalendarTableViewCell: UITableViewCell{
    var didTapItem: ((MyPageIPickSocialCalendarCollectionViewCell.Item) -> Void)?
    var scrolledToLast: (() -> Void)?
    private var collectionViewHeightConstraint: Constraint?
    private var collectionViewEdgesConstraint: Constraint?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update(with item: Item){
        UIView.transition(with: placeholderLabel, duration: 0.3) {
            self.collectionView.alpha = item.calendars.isEmpty ? 0 : 1
            self.placeholderLabel.alpha = item.calendars.isEmpty ? 1 : 0
        }
        self.items = item.calendars

        collectionView.reloadData()
        setNeedsUpdateConstraints()
    }
    
    override func updateConstraints() {
        collectionViewEdgesConstraint?.update(priority: items.isEmpty ? .high : .required)
        
        if !items.isEmpty {
            collectionViewHeightConstraint?.update(offset: 228 + collectionView.contentInset.top + collectionView.contentInset.bottom)
        }
        
        placeholderLabel.snp.makeConstraints{
            $0.top.equalToSuperview().inset(56).priority(items.isEmpty ? .required : .high)
            $0.leading.greaterThanOrEqualToSuperview()
            $0.trailing.lessThanOrEqualToSuperview()
            $0.bottom.equalToSuperview().inset(100).priority(items.isEmpty ? .required : .high)
            $0.centerX.equalToSuperview()
        }
        
        super.updateConstraints()
    }
    
    // MARK: - UI Properties
    private let placeholderLabel = {
        let label = UILabel()
        label.text = """
        아직 저장한 일정이 없어요.
        가고 싶은 일정을 저장해보세요!
        """
        label.textColor = Color.gray700
        label.font = Typo.Body2()
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    private lazy var collectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: {
            let layout = UICollectionViewFlowLayout()
            layout.scrollDirection = .horizontal
            return layout
        }())
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.contentInset = UIEdgeInsets(top: 12, left: 20, bottom: 68, right: 20)
        collectionView.register(MyPageIPickSocialCalendarCollectionViewCell.self, forCellWithReuseIdentifier: String(describing: MyPageIPickSocialCalendarCollectionViewCell.self))
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = .white
        return collectionView
    }()
    
    // MARK: - Private
    private var items: [MyPageIPickSocialCalendarCollectionViewCell.Item] = []
}

private extension MyPageIPickSocialCalendarTableViewCell{
    func setupUI(){
        contentView.backgroundColor = .white 
        selectionStyle = .none
        contentView.addSubview(collectionView)
        contentView.addSubview(placeholderLabel)
        
        collectionView.snp.makeConstraints { make in
            collectionViewEdgesConstraint = make.edges.equalToSuperview().priority(.required).constraint
            collectionViewHeightConstraint = make.height.greaterThanOrEqualTo(228).constraint
        }
    }
}

extension MyPageIPickSocialCalendarTableViewCell: UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let height = collectionView.bounds.height - collectionView.contentInset.top - collectionView.contentInset.bottom
        return CGSize(width: 160, height: height)
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

extension MyPageIPickSocialCalendarTableViewCell: UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: MyPageIPickSocialCalendarCollectionViewCell.self), for: indexPath) as? MyPageIPickSocialCalendarCollectionViewCell else{
            return UICollectionViewCell()
        }
        cell.update(with: items[indexPath.row])
        return cell
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        items.count
    }
}

extension MyPageIPickSocialCalendarTableViewCell{
    struct Item{
        let calendars: [MyPageIPickSocialCalendarCollectionViewCell.Item]
    }
}

struct MyPageIPickSocialCalendarTableViewCell_Previews: PreviewProvider{
    static var previews: some View{
        ViewPreview{
            MyPageIPickSocialCalendarTableViewCell()
        }
    }
}


