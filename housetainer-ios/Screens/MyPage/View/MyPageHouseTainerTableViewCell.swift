//
//  MyPageHouseTainerTableViewCell.swift
//  housetainer-ios
//
//  Created by 김수아 on 1/3/24.
//

import Foundation
import UIKit
import SwiftUI
import SnapKit

final class MyPageHouseTainerTableViewCell: UITableViewCell{
    var didTapItem: ((MyPageHouseTainerCollectionViewCell.Item) -> Void)?
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
        UIView.transition(with: placeholderContainer, duration: 0.3) {
            self.collectionView.alpha = item.houseTainers.isEmpty ? 0 : 1
            self.placeholderContainer.alpha = item.houseTainers.isEmpty ? 1 : 0
            self.collectionView.constraints.forEach{ $0.isActive = !item.houseTainers.isEmpty }
        }
        self.items = item.houseTainers
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
        collectionView.register(MyPageHouseTainerCollectionViewCell.self, forCellWithReuseIdentifier: String(describing: MyPageHouseTainerCollectionViewCell.self))
        collectionView.showsHorizontalScrollIndicator = false
        return collectionView
    }()
    
    private let placeholderContainer = UIView()
    private let placeholderIconImageView = {
        let imageView = UIImageView()
        imageView.image = Image.houseNo
        return imageView
    }()
    private let placeholderLabel = {
        let label = UILabel()
        label.font = Typo.Body3()
        label.textColor = Color.gray600
        label.text = """
        아직 등록된
        집 소개가 없어요.
        """
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    private let houseTainerCell = MyPageHouseTainerCollectionViewCell()
    
    // MARK: - Private
    private var items: [MyPageHouseTainerCollectionViewCell.Item] = []
}

private extension MyPageHouseTainerTableViewCell{
    func setupUI(){
        selectionStyle = .none
        contentView.addSubview(collectionView)
        contentView.addSubview(placeholderContainer)
        placeholderContainer.addSubview(placeholderIconImageView)
        placeholderContainer.addSubview(placeholderLabel)
        
        collectionView.snp.makeConstraints{
            $0.edges.equalToSuperview()
            $0.height.greaterThanOrEqualTo(208 + collectionView.contentInset.top + collectionView.contentInset.bottom)
        }
        
        placeholderContainer.snp.makeConstraints{
            $0.top.equalToSuperview()
            $0.leading.greaterThanOrEqualToSuperview()
            $0.bottom.trailing.lessThanOrEqualToSuperview()
            $0.centerX.equalToSuperview()
        }
        
        placeholderIconImageView.snp.makeConstraints{
            $0.top.equalToSuperview()
            $0.leading.greaterThanOrEqualToSuperview()
            $0.trailing.lessThanOrEqualToSuperview()
            $0.centerX.equalToSuperview()
            $0.size.equalTo(66)
        }
        
        placeholderLabel.snp.makeConstraints{
            $0.top.equalTo(placeholderIconImageView.snp.bottom).offset(4)
            $0.directionalHorizontalEdges.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
    }
}

extension MyPageHouseTainerTableViewCell: UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.bounds.width - collectionView.contentInset.left - collectionView.contentInset.right
        let height = collectionView.bounds.height - collectionView.contentInset.top - collectionView.contentInset.bottom
        houseTainerCell.update(with: items[indexPath.row])
        houseTainerCell.updateWidth(width)
        return houseTainerCell.systemLayoutSizeFitting(CGSize(width: UIView.layoutFittingCompressedSize.width, height: height))
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

extension MyPageHouseTainerTableViewCell: UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let width = collectionView.bounds.width - collectionView.contentInset.left - collectionView.contentInset.right
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: MyPageHouseTainerCollectionViewCell.self), for: indexPath) as? MyPageHouseTainerCollectionViewCell else{
            return UICollectionViewCell()
        }
        cell.update(with: items[indexPath.row])
        cell.updateWidth(width)
        return cell
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        items.count
    }
}

extension MyPageHouseTainerTableViewCell{
    struct Item{
        let houseTainers: [MyPageHouseTainerCollectionViewCell.Item]
    }
}

struct MyPageHouseTainerTableViewCell_Previews: PreviewProvider{
    static var previews: some View{
        ViewPreview{
            MyPageHouseTainerTableViewCell()
        }
    }
}


