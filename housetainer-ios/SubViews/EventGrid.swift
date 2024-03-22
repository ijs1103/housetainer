//
//  EventGrid.swift
//  Housetainer
//
//  Created by 이주상 on 2023/11/17.
//

import UIKit
import SnapKit

protocol EventGridDelegate: AnyObject {
    func didTapGridCell(event: EventWithNickname)
}

final class EventGrid: UIView {
    enum Section {
        case main
    }
    weak var delegate: EventGridDelegate?
    private var dataSource: UICollectionViewDiffableDataSource<Section, Int>! = nil
    private var collectionView: UICollectionView! = nil
    private var events: [EventWithNickname] = []

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

extension EventGrid {
    private func layout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                              heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                               heightDimension: .absolute(EventGridCell.width + 96.0))
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
        let cellRegistration = UICollectionView.CellRegistration<EventGridCell, Int> { [weak self] (cell, indexPath, identifier) in
            guard let self, !events.isEmpty else { return }
            let event = events[indexPath.item]
            cell.configure(with: event)
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
    
    func configure(with events: [EventWithNickname]) {
        self.events = events
    }
    
    func reloadData() {
        collectionView.reloadData()
    }
}

extension EventGrid: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let event = events[indexPath.row]
        delegate?.didTapGridCell(event: event)
    }
}
