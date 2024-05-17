//
//  TabView.swift
//  housetainer-ios
//
//  Created by 김수아 on 1/7/24.
//

import Foundation
import UIKit
import SnapKit
import SwiftUI

final class TabView: UIView{
    typealias Item = TabItemCollectionViewCell.Item
    
    var selectedIndexPath: IndexPath{
        get{ collectionView.indexPathsForSelectedItems?.first ?? .zero }
        set{
            guard newValue != selectedIndexPath else{ return }
            needsSelection = true
            updateSelection()
        }
    }
    var items: [Item] = []{
        didSet{
            guard oldValue != items else{ return }
            collectionView.reloadData()
        }
    }
    var showsUnderline: Bool = true{
        didSet{
            guard oldValue != showsUnderline else{ return }
            updateUnderline()
        }
    }
    var underlineInset: UIEdgeInsets = .zero{
        didSet{
            guard oldValue != underlineInset else{ return }
            updateUnderline()
        }
    }
    
    var didSelectTab: ((IndexPath) -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        updateSelection()
        updateUnderline()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI Properties
    private var needsSelection = false
    private lazy var collectionView = {
        let collectionView = HTCollectionView(frame: .zero, collectionViewLayout: {
            let layout = UICollectionViewFlowLayout()
            layout.scrollDirection = .horizontal
            return layout
        }())
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 7.5, bottom: 0, right: 7.5)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .clear
        collectionView.register(TabItemCollectionViewCell.self, forCellWithReuseIdentifier: String(describing: TabItemCollectionViewCell.self))
        collectionView.didLayout = { [weak self] in
            guard let self else{ return }
            if needsSelection || collectionView.indexPathsForSelectedItems?.first == nil{
                updateSelection()
            }
        }
        return collectionView
    }()
    private let indicator = {
        let view = UIView()
        view.backgroundColor = Color.black
        return view
    }()
    private let underline = {
        let view = UIView()
        view.backgroundColor = Color.gray200
        return view
    }()
}

extension TabView: UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: TabItemCollectionViewCell.self), for: indexPath) as? TabItemCollectionViewCell else{ return .zero }
        cell.update(with: items[indexPath.item])
        return cell.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        didSelectTab?(indexPath)
        
        needsSelection = true
        updateSelection(animated: true)
    }
}

extension TabView: UICollectionViewDataSource{
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: TabItemCollectionViewCell.self), for: indexPath) as? TabItemCollectionViewCell else{ return UICollectionViewCell() }
        cell.update(with: items[indexPath.item])
        return cell
    }
}

private extension TabView{
    func setupUI(){
        addSubview(underline)
        addSubview(collectionView)
        collectionView.addSubview(indicator)
        
        collectionView.snp.makeConstraints{
            $0.directionalEdges.equalToSuperview()
            $0.height.greaterThanOrEqualTo(16 + 24 + 16)
        }
        
        underline.snp.makeConstraints{
            $0.directionalHorizontalEdges.equalToSuperview()
            $0.bottom.equalToSuperview()
            $0.height.equalTo(1)
        }
    }
    
    func updateSelection(animated: Bool = false){
        guard !items.isEmpty else{ return }
        guard selectedIndexPath.section < collectionView.numberOfSections else{ return }
        guard selectedIndexPath.item < collectionView.numberOfItems(inSection: selectedIndexPath.section) else{ return }
        
        if collectionView.indexPathsForSelectedItems?.first != selectedIndexPath{
            collectionView.selectItem(at: selectedIndexPath, animated: true, scrollPosition: .centeredHorizontally)
        }
        
        if let cell = collectionView.cellForItem(at: selectedIndexPath){
            let animation = {
                self.indicator.frame.size.width = cell.frame.width - 12.5 * 2
                self.indicator.frame.size.height = 4
                self.indicator.frame.origin.x = cell.frame.minX + 12.5
                self.indicator.frame.origin.y = cell.frame.maxY - self.indicator.frame.height
            }
            
            if animated{
                UIView.animate(withDuration: 0.3, animations: animation)
            }else{
                animation()
            }
        }
        
        needsSelection = false
    }
    
    func updateUnderline(){
        underline.isHidden = !showsUnderline
        
        underline.snp.updateConstraints{
            $0.directionalHorizontalEdges.equalToSuperview().inset(underlineInset)
            $0.bottom.equalToSuperview().inset(underlineInset)
            $0.height.equalTo(1)
        }
    }
}

struct TabView_Preview: PreviewProvider{
    static var previews: some View{
        Group{
            ViewPreview{
                let tabView = TabView()
                tabView.items = [.init(title: "Activated"), .init(title: "Inactive"), .init(title: "Inactive"), .init(title: "Inactive")]
                return tabView
            }
            
            ViewPreview{
                let cell = TabItemCollectionViewCell()
                cell.update(with: .init(title: "Inactive"))
                return cell
            }
        }
    }
}
