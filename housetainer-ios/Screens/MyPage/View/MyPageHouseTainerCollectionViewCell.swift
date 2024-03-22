//
//  MyPageHouseTainerCollectionViewCell.swift
//  housetainer-ios
//
//  Created by 김수아 on 1/4/24.
//

import Foundation
import UIKit
import SwiftUI
import SnapKit
import Kingfisher

final class MyPageHouseTainerCollectionViewCell: UICollectionViewCell{
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update(with item: Item){
        mainImageView.kf.setImage(with: item.mainURL)
        titleLabel.text = item.title
        setNeedsUpdateConstraints()
    }
    
    func updateWidth(_ width: CGFloat){
        mainImageView.snp.makeConstraints{
            $0.width.equalTo(width)
        }
        setNeedsUpdateConstraints()
    }
    
    // MARK: - UI Properties
    private let mainImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 16
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private let titleLabel = {
        let label = UILabel()
        label.font = Typo.Body3()
        label.textColor = Color.black
        label.numberOfLines = 0
        return label
    }()
}

private extension MyPageHouseTainerCollectionViewCell{
    func setupUI(){
        contentView.addSubview(mainImageView)
        contentView.addSubview(titleLabel)
        
        mainImageView.snp.makeConstraints{
            $0.top.horizontalEdges.equalToSuperview()
            $0.height.equalTo(184)
        }
        
        titleLabel.snp.makeConstraints{
            $0.top.equalTo(mainImageView.snp.bottom).offset(8)
            $0.leading.bottom.equalToSuperview()
            $0.trailing.lessThanOrEqualToSuperview()
        }
    }
}

extension MyPageHouseTainerCollectionViewCell{
    struct Item{
        let id: String
        let mainURL: URL?
        let title: String
    }
}

struct MyPageHouseTainerCollectionViewCell_Previews: PreviewProvider{
    static var previews: some View{
        ViewPreview{
            let cell = MyPageHouseTainerCollectionViewCell()
            cell.update(with: .init(
                id: "",
                mainURL: URL(string: "https://placekitten.com/200/200")!,
                title: "김길동"
            ))
            return cell
        }
    }
}


