//
//  HorizontalPhotoSlider.swift
//  housetainer-ios
//
//  Created by 김수아 on 1/14/24.
//

import Foundation
import SwiftUI
import UIKit
import SnapKit

final class HorizontalPhotoSlider: UIView{
    var didTapNew: (() -> Void)?
    var maxLength: Int = 1{
        didSet{
            guard maxLength != oldValue else{ return }
            trimItems()
        }
    }
    var items: [Item] = []{
        didSet{
            trimItems()
            collectionView.reloadData()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        define()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI Properties
    private lazy var collectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: {
            let layout = UICollectionViewFlowLayout()
            layout.scrollDirection = .horizontal
            layout.minimumInteritemSpacing = 10
            return layout
        }())
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(PhotoListItemCollectionViewCell.self, forCellWithReuseIdentifier: String(describing: PhotoListItemCollectionViewCell.self))
        collectionView.register(PhotoListAddItemCollectionViewCell.self, forCellWithReuseIdentifier: String(describing: PhotoListAddItemCollectionViewCell.self))
        collectionView.backgroundColor = .clear
        return collectionView
    }()
    
    // MARK: - Private
}

private extension HorizontalPhotoSlider{
    func setupUI(){
        addSubview(collectionView)
    }
    
    func define(){
        collectionView.snp.makeConstraints{
            $0.directionalEdges.equalToSuperview()
        }
    }
    
    func trimItems(){
        if items.count > maxLength{
            items = Array(items.prefix(maxLength))
        }
    }
}

extension HorizontalPhotoSlider{
    typealias Item = PhotoListItemCollectionViewCell.Item
}

extension HorizontalPhotoSlider: UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 88, height: 85)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.item == 0{
            didTapNew?()
        }
    }
}

extension HorizontalPhotoSlider: UICollectionViewDataSource{
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        items.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.item == 0{
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: PhotoListAddItemCollectionViewCell.self), for: indexPath) as? PhotoListAddItemCollectionViewCell else{ return UICollectionViewCell() }
            cell.update(with: .init(numberOfPhotos: items.count, maximum: maxLength))
            return cell
        }else{
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: PhotoListItemCollectionViewCell.self), for: indexPath) as? PhotoListItemCollectionViewCell else{ return UICollectionViewCell() }
            let item = items[indexPath.item - 1]
            cell.update(with: item)
            cell.didTapDelete = { [weak self, indexPath] in
                guard let self else{ return }
                var newItems = items
                newItems.remove(at: max(0, indexPath.item - 1))
                items = newItems
            }
            return cell
        }
    }
}

struct HorizontalPhotoSlider_Previews: PreviewProvider{
    static var previews: some View{
        ViewPreview{
            HorizontalPhotoSlider()
        }.frame(height: 85)
    }
}
