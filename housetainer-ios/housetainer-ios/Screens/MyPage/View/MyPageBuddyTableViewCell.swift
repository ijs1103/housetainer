//
//  MyPageBuddyTableViewCell.swift
//  housetainer-ios
//
//  Created by 김수아 on 1/3/24.
//

import Foundation
import UIKit
import SwiftUI
import SnapKit

final class MyPageBuddyTableViewCell: UITableViewCell{
    var didTapNew: (() -> Void)?
    var didTapBuddy: ((Item.PrivateBuddy) -> Void)?
    var didTapPublicBuddy: ((Item.PublicBuddy) -> Void)?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update(with items: [Item], mode: Mode){
        self.mode = mode
        self.items = items
        
        collectionView.snp.remakeConstraints{
            $0.directionalEdges.equalToSuperview()
            $0.height.equalTo(mode.collectionHeight + collectionView.contentInset.top + collectionView.contentInset.bottom)
        }
        collectionView.reloadData()
    }
    
    // MARK: - UI Properties
    private lazy var collectionView = {
        let collectionView = HTCollectionView(frame: .zero, collectionViewLayout: {
            let layout = UICollectionViewFlowLayout()
            layout.scrollDirection = .horizontal
            return layout
        }())
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .clear
        collectionView.contentInset = .init(top: 12, left: 20, bottom: 28, right: 20)
        collectionView.register(MyPageNewBuddyCollectionViewCell.self, forCellWithReuseIdentifier: String(describing: MyPageNewBuddyCollectionViewCell.self))
        collectionView.register(MyPageBuddyCollectionViewCell.self, forCellWithReuseIdentifier: String(describing: MyPageBuddyCollectionViewCell.self))
        collectionView.register(MyPagePublicBuddyCollectionViewCell.self, forCellWithReuseIdentifier: String(describing: MyPagePublicBuddyCollectionViewCell.self))
        collectionView.backgroundColor = .white
        return collectionView
    }()
    
    private let newCell = MyPageNewBuddyCollectionViewCell()
    private let buddyCell = MyPageBuddyCollectionViewCell()
    private let publicBuddyCell = MyPagePublicBuddyCollectionViewCell()
    
    // MARK: - Private
    private var mode: Mode = .private
    private var items: [Item] = [.new]
}

private extension MyPageBuddyTableViewCell{
    func setupUI(){
        selectionStyle = .none
        contentView.addSubview(collectionView)
        
        collectionView.snp.makeConstraints{
            $0.directionalEdges.equalToSuperview()
        }
    }
}


extension MyPageBuddyTableViewCell: UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        11
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let layout = collectionViewLayout as? UICollectionViewFlowLayout else{ return .zero }
        let numberOfItems: CGFloat = CGFloat(collectionView.numberOfItems(inSection: 0))
        
        let width: CGFloat = collectionView.bounds.width
            - collectionView.contentInset.left
            - collectionView.contentInset.right
            - (layout.minimumInteritemSpacing * max(0, numberOfItems - 1))
        let height = collectionView.bounds.height - collectionView.contentInset.top - collectionView.contentInset.bottom
        return CGSize(width: floor(width / numberOfItems), height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = items[indexPath.item]
        switch item{
        case .new:
            didTapNew?()
        case let .buddy(item):
            didTapBuddy?(item)
        case let .publicBuddy(item):
            didTapPublicBuddy?(item)
        }
    }
}

extension MyPageBuddyTableViewCell: UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch items[indexPath.item]{
        case .new:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: MyPageNewBuddyCollectionViewCell.self), for: indexPath) as? MyPageNewBuddyCollectionViewCell else{
                return UICollectionViewCell()
            }
            
            return cell
        case let .buddy(item):
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: MyPageBuddyCollectionViewCell.self), for: indexPath) as? MyPageBuddyCollectionViewCell else{
                return UICollectionViewCell()
            }
            cell.update(with: item)
            return cell
        case let .publicBuddy(item):
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: MyPagePublicBuddyCollectionViewCell.self), for: indexPath) as? MyPagePublicBuddyCollectionViewCell else{
                return UICollectionViewCell()
            }
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

extension MyPageBuddyTableViewCell{
    enum Item: Equatable{
        case new
        case buddy(PrivateBuddy)
        case publicBuddy(PublicBuddy)
        
        typealias PrivateBuddy = MyPageBuddyCollectionViewCell.Item
        typealias PublicBuddy = MyPagePublicBuddyCollectionViewCell.Item
    }
}

extension MyPageBuddyTableViewCell{
    enum Mode{
        case `private`
        case `public`
        
        var collectionHeight: CGFloat{
            switch self{
            case .private:
                return 172
            case .public:
                return 128
            }
        }
    }
}

private extension MyPageBuddyTableViewCell.Item{
    var isPrivateBuddy: Bool{
        if case .buddy = self{
            return true
        }
        return false
    }
    
    var isPublicBuddy: Bool{
        if case .publicBuddy = self{
            return true
        }
        return false
    }
}

struct MyPageBuddyTableViewCell_Previews: PreviewProvider{
    static var previews: some View{
        ViewPreview{
            MyPageBuddyTableViewCell()
        }
    }
}

