//
//  HouseGrid.swift
//  Housetainer
//
//  Created by 이주상 on 2023/11/17.
//

import UIKit
import SnapKit

protocol HouseGridDelegate: AnyObject {
    func didTapGridCell(house: HouseWithNickname)
}

final class HouseGrid: UIView {
    enum Section {
        case main
    }
    weak var delegate: HouseGridDelegate?
    private var dataSource: UICollectionViewDiffableDataSource<Section, Int>! = nil
    private var collectionView: UICollectionView! = nil
    private var houses: [HouseWithNickname] = []

    init() {
        super.init(frame: .zero)
        configureHierarchy()
        configureDataSource()
        setUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension HouseGrid {
    private func layout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                              heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                               heightDimension: .absolute(HouseGridCell.width + 26.0))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 2)
        let spacing = CGFloat(10)
        group.interItemSpacing = .fixed(spacing)
        
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = CGFloat(28)

        let layout = UICollectionViewCompositionalLayout(section: section)
        return layout
    }
    
    func configureHierarchy() {
        collectionView = UICollectionView(frame: self.bounds, collectionViewLayout: layout())
        collectionView.backgroundColor = .white
        collectionView.showsVerticalScrollIndicator = false
        collectionView.isScrollEnabled = false 
        collectionView.delegate = self
    }
    
    func configureDataSource() {
        let cellRegistration = UICollectionView.CellRegistration<HouseGridCell, Int> { [weak self] (cell, indexPath, identifier) in
            guard let self, !houses.isEmpty else { return }
            let house = houses[indexPath.item]
            cell.configure(with: house)
        }
        
        dataSource = UICollectionViewDiffableDataSource<Section, Int>(collectionView: collectionView) {
            (collectionView: UICollectionView, indexPath: IndexPath, identifier: Int) -> UICollectionViewCell? in
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: identifier)
        }

        var snapshot = NSDiffableDataSourceSnapshot<Section, Int>()
        snapshot.appendSections([.main])
        snapshot.appendItems(Array(0..<4))
        dataSource.apply(snapshot, animatingDifferences: false)
    }
    
    private func setUI() {
        addSubview(collectionView)
        
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    func configure(with houses: [HouseWithNickname]) {
        self.houses = houses
    }
    
    func reloadData() {
        collectionView.reloadData()
    }
}

extension HouseGrid: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let house = houses[indexPath.row]
        delegate?.didTapGridCell(house: house)
    }
}
