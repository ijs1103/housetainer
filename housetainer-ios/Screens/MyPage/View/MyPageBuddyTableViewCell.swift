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
    
    func update(with items: [Item]){
        precondition(!(items.contains(where: { $0.isPrivateBuddy }) && items.contains(where: { $0.isPublicBuddy })), "Item.buddy 와 Item.privateBuddy를 같이 사용할 수 없습니다.")
        if items.contains(where: { $0.isPublicBuddy }){
            mode = .public
        }else{
            mode = .private
        }
        self.items = items
        
        collectionView.snp.updateConstraints{
            $0.height.equalTo(mode.collectionHeight + collectionView.contentInset.top + collectionView.contentInset.bottom)
        }
        collectionView.reloadData()
    }
    
    // MARK: - UI Properties
    private lazy var collectionView = {
        let collectionView = HTCollectionView(frame: .zero, collectionViewLayout: {
            let layout = UICollectionViewFlowLayout()
            layout.scrollDirection = .horizontal
            layout.estimatedItemSize = .init(width: 103, height: 144)
            return layout
        }())
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .clear
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 20, bottom: 40, right: 20)
        collectionView.register(MyPageNewBuddyCollectionViewCell.self, forCellWithReuseIdentifier: String(describing: MyPageNewBuddyCollectionViewCell.self))
        collectionView.register(MyPageBuddyCollectionViewCell.self, forCellWithReuseIdentifier: String(describing: MyPageBuddyCollectionViewCell.self))
        collectionView.register(MyPagePublicBuddyCollectionViewCell.self, forCellWithReuseIdentifier: String(describing: MyPagePublicBuddyCollectionViewCell.self))
        collectionView.didLayout = { [weak self] in
            guard let self else{ return }
            if items == [.new]{
                let itemWidth = newCell.systemLayoutSizeFitting(CGSize(width: UIView.layoutFittingCompressedSize.width, height: collectionView.bounds.height)).width
                let horizontalInset = (collectionView.bounds.width - itemWidth) / 2
                collectionView.contentInset = UIEdgeInsets(top: 0, left: horizontalInset, bottom: 40, right: horizontalInset)
            }else if case .private = mode{
                collectionView.contentInset = UIEdgeInsets(top: 0, left: 20, bottom: 40, right: 20)
            }else{
                collectionView.contentInset = UIEdgeInsets(top: 0, left: 32, bottom: 40, right: 32)
            }
        }
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
            $0.edges.equalToSuperview()
            $0.height.equalTo(144 + collectionView.contentInset.top + collectionView.contentInset.bottom)
        }
    }
}


extension MyPageBuddyTableViewCell: UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let height = collectionView.bounds.height - collectionView.contentInset.top - collectionView.contentInset.bottom
        switch items[indexPath.item]{
        case .new:
            return newCell.systemLayoutSizeFitting(CGSize(width: UIView.layoutFittingCompressedSize.width, height: height))
        case .buddy:
            return buddyCell.systemLayoutSizeFitting(CGSize(width: UIView.layoutFittingCompressedSize.width, height: height))
        case .publicBuddy:
            return publicBuddyCell.systemLayoutSizeFitting(CGSize(width: UIView.layoutFittingCompressedSize.width, height: height))
        }
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

private extension MyPageBuddyTableViewCell{
    enum Mode{
        case `private`
        case `public`
        
        var collectionHeight: CGFloat{
            switch self{
            case .private:
                return 144
            case .public:
                return 104
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

