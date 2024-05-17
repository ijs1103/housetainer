//
//  SheetView.swift
//  housetainer-ios
//
//  Created by 김수아 on 3/20/24.
//

import Foundation
import UIKit
import SnapKit

final class SheetView: UIView{
    var items: [Item] = []{
        didSet{
            collectionView.reloadData()
        }
    }
    var spanCount: Int = 1{
        didSet{
            collectionView.collectionViewLayout.invalidateLayout()
        }
    }
    var didTapDim: (() -> Void)? = nil
    var didTapItem: ((Item) -> Void)? = nil
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Private
    private lazy var dimView = {
        let view = UIControl()
        view.addTarget(self, action: #selector(didTapDimBackgroundAction), for: .touchUpInside)
        return view
    }()
    private let backgroundView = {
        let view = UIView()
        view.backgroundColor = .white
        view.insetsLayoutMarginsFromSafeArea = true
        return view
    }()
    private lazy var collectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: {
            let layout = UICollectionViewFlowLayout()
            layout.scrollDirection = .vertical
            return layout
        }())
        collectionView.backgroundColor = .clear
        collectionView.register(SheetItemCollectionViewCell.self, forCellWithReuseIdentifier: SheetItemCollectionViewCell.id)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.contentInset = .init(top: 25, left: 0, bottom: 25, right: 0)
        collectionView.contentInsetAdjustmentBehavior = .always
        return collectionView
    }()
    
}

extension SheetView{
    typealias Item = SheetItemCollectionViewCell.Item
}

extension SheetView: UICollectionViewDataSource{
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SheetItemCollectionViewCell.id, for: indexPath) as! SheetItemCollectionViewCell
        cell.configure(with: items[indexPath.item])
        return cell
    }
}

extension SheetView: UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.bounds.width - collectionView.adjustedContentInset.left - collectionView.adjustedContentInset.right
        let spanWidth = floor(width / CGFloat(spanCount))
        return CGSize(width: spanWidth, height: 40)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        8
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        0
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = items[indexPath.item]
        didTapItem?(item)
    }
}

private extension SheetView{
    func setupUI(){
        backgroundColor = .black.withAlphaComponent(0.4)
        
        backgroundView.backgroundColor = Color.white
        backgroundView.layer.cornerRadius = 12
        backgroundView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        backgroundView.layer.masksToBounds = true
        
        addSubview(dimView)
        addSubview(backgroundView)
        backgroundView.addSubview(collectionView)
        dimView.snp.makeConstraints{
            $0.top.horizontalEdges.equalToSuperview()
            $0.bottom.equalTo(collectionView.snp.top)
        }
        backgroundView.snp.makeConstraints{
            $0.horizontalEdges.bottom.equalToSuperview()
        }
        collectionView.snp.makeConstraints{
            $0.edges.equalTo(backgroundView.snp.margins)
            $0.height.equalTo(232)
        }
      
    }
    
    @objc func didTapDimBackgroundAction(){
        didTapDim?()
    }
}


