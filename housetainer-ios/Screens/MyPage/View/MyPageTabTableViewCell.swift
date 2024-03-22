//
//  MyPageTabTableViewCell.swift
//  housetainer-ios
//
//  Created by 김수아 on 1/7/24.
//

import Foundation
import UIKit
import SwiftUI
import SnapKit

final class MyPageTabTableViewCell: UITableViewCell{
    var didTapItem: ((Int) -> Void)?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update(with item: Item, selectedIndex: Int){
        tabView.items = item.items
        tabView.selectedIndexPath = IndexPath(item: selectedIndex, section: 0)
        self.item = item
    }
    
    // MARK: - Private
    private var item = Item(items: [])
    
    // MARK: - UI Properties
    private lazy var tabView = {
        let tabView = TabView()
        tabView.underlineInset = .init(top: 0, left: 0, bottom: 0, right: 15)
        tabView.didSelectTab = { [weak self] index in
            guard let self else{ return }
            didTapItem?(index.item)
        }
        return tabView
    }()
}

extension MyPageTabTableViewCell{
    struct Item{
        let items: [TabView.Item]
    }
}

private extension MyPageTabTableViewCell{
    func setupUI(){
        selectionStyle = .none
        contentView.layoutMargins = UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0)
        contentView.addSubview(tabView)
        
        tabView.snp.makeConstraints{
            $0.top.horizontalEdges.equalToSuperview()
            $0.bottom.equalTo(contentView.snp.bottomMargin)
        }
    }
}

struct MyPageTabTableViewCell_Previews: PreviewProvider{
    static var previews: some View{
        ViewPreview{
            let cell = MyPageTabTableViewCell()
            cell.update(with: .init(items: [.init(title: "MY"), .init(title: "PICK")]), selectedIndex: 0)
            return cell
        }
    }
}



