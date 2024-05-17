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
    
    override func updateConstraints() {
        mainImageView.snp.updateConstraints{
            $0.directionalEdges.equalTo(contentView.snp.directionalEdges)
        }
        
        titleLabel.snp.updateConstraints{
            $0.leading.equalTo(contentView.snp.leadingMargin)
            $0.bottom.equalTo(contentView.snp.bottomMargin)
        }
        super.updateConstraints()
    }
    
    // MARK: - UI Properties
    private let mainImageView = {
        let imageView = HTImageView(frame: .zero)
        imageView.layer.cornerRadius = 16
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.layer.addSublayer({
            let layer = CAGradientLayer()
            layer.colors = [
                Color.black.withAlphaComponent(0).cgColor,
                Color.black.cgColor
            ]
            layer.opacity = 0.8
            return layer
        }())
        imageView.didLayout = { [weak imageView] in
            guard let imageView else{ return }
            for sublayer in imageView.layer.sublayers ?? []{
                sublayer.frame = imageView.bounds
            }
        }
        return imageView
    }()
    
    private let titleLabel = {
        let label = UILabel()
        label.font = Typo.Body1Medium()
        label.textColor = Color.white
        label.numberOfLines = 0
        return label
    }()
}

private extension MyPageHouseTainerCollectionViewCell{
    func setupUI(){
        contentView.layoutMargins = .init(top: 20, left: 20, bottom: 20, right: 20)
        contentView.addSubview(mainImageView)
        contentView.addSubview(titleLabel)
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


