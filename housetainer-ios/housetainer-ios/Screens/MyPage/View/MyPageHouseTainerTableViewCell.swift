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
    var didTapContact: (() -> Void)?
    
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
        }
        self.items = item.houseTainers
        
        if !item.isHouseTainer{
            placeholderLabel.text = """
            우리집 소개는 Housetainer 등급만 가능해요.
            소개를 원하시면 하단의 버튼을 통해 문의해주세요!
            """
        }else{
            placeholderLabel.text = """
            아직 우리집 소개를 하지 않았어요.
            소개를 원하시면 하단의 버튼을 통해 문의해주세요!
            """
        }
        
        collectionView.reloadData()
        setNeedsUpdateConstraints()
    }
    
    override func updateConstraints() {
        collectionView.snp.remakeConstraints{
            $0.directionalEdges.equalToSuperview().priority(items.isEmpty ? .high : .required)
            if !items.isEmpty{
                $0.height.equalTo(204 + collectionView.contentInset.top + collectionView.contentInset.bottom).priority(.high)
            }
        }
        
        placeholderContainer.snp.remakeConstraints{
            $0.top.equalToSuperview().inset(12).priority(items.isEmpty ? .required : .high)
            $0.leading.greaterThanOrEqualToSuperview()
            $0.trailing.lessThanOrEqualToSuperview()
            $0.bottom.lessThanOrEqualToSuperview().priority(items.isEmpty ? .required : .high)
            $0.centerX.equalToSuperview()
        }
        
        placeholderIconImageView.snp.updateConstraints{
            $0.top.equalToSuperview()
            $0.leading.greaterThanOrEqualToSuperview()
            $0.trailing.lessThanOrEqualToSuperview()
            $0.centerX.equalToSuperview()
            $0.size.equalTo(66)
        }
        
        placeholderLabel.snp.updateConstraints{
            $0.top.equalTo(placeholderIconImageView.snp.bottom).offset(4)
            $0.directionalHorizontalEdges.equalToSuperview()
        }
        
        contactButton.snp.updateConstraints{
            $0.top.equalTo(placeholderLabel.snp.bottom).offset(12)
            $0.leading.greaterThanOrEqualToSuperview()
            $0.trailing.lessThanOrEqualToSuperview()
            $0.centerX.equalToSuperview()
            $0.bottom.equalToSuperview().inset(28)
            $0.width.greaterThanOrEqualTo(200)
        }
        
        notMyPageEmptyHousesLabel.snp.updateConstraints {
            $0.center.equalToSuperview()
        }
        
        super.updateConstraints()
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
        collectionView.contentInset = UIEdgeInsets(top: 12, left: 20, bottom: 28, right: 20)
        collectionView.register(MyPageHouseTainerCollectionViewCell.self, forCellWithReuseIdentifier: String(describing: MyPageHouseTainerCollectionViewCell.self))
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = .white
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
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    private lazy var contactButton = {
        let button = UIButton()
        button.contentEdgeInsets = .init(top: 12, left: 24, bottom: 12, right: 24)
        button.titleLabel?.font = Typo.Body3Medium()
        button.setTitle("집 소개 문의", for: .normal)
        button.setTitleColor(Color.reddishPurple600, for: .normal)
        button.layer.borderWidth = 1
        button.layer.borderColor = Color.reddishPurple600.cgColor
        button.layer.cornerRadius = 8
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(didTapContactAction), for: .touchUpInside)
        return button
    }()
    
    private let notMyPageEmptyHousesLabel: UILabel = {
        let label = LabelFactory.build(text: Title.notMyProfileEmptyHouses, font: Typo.Body3(), textColor: Color.gray600)
        label.numberOfLines = 2
        label.isHidden = true
        return label
    }()
    
    // MARK: - Private
    private var items: [MyPageHouseTainerCollectionViewCell.Item] = []
}

extension MyPageHouseTainerTableViewCell {
    func handleNotMypage() {
        placeholderContainer.isHidden = true
        notMyPageEmptyHousesLabel.isHidden = false
    }
}

private extension MyPageHouseTainerTableViewCell{
    func setupUI(){
        contentView.backgroundColor = .white 
        selectionStyle = .none
        contentView.addSubview(collectionView)
        contentView.addSubview(placeholderContainer)
        contentView.addSubview(notMyPageEmptyHousesLabel)
        placeholderContainer.addSubview(placeholderIconImageView)
        placeholderContainer.addSubview(placeholderLabel)
        placeholderContainer.addSubview(contactButton)
    }
    
    @objc func didTapContactAction(){
        didTapContact?()
    }
}

extension MyPageHouseTainerTableViewCell: UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.bounds.width - collectionView.contentInset.left - collectionView.contentInset.right
        let height = collectionView.bounds.height - collectionView.contentInset.top - collectionView.contentInset.bottom
        return CGSize(width: width, height: height)
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
        let isHouseTainer: Bool
    }
}

struct MyPageHouseTainerTableViewCell_Previews: PreviewProvider{
    static var previews: some View{
        ViewPreview{
            MyPageHouseTainerTableViewCell()
        }
    }
}


