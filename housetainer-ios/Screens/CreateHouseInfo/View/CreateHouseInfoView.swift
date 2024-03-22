//
//  CreateHouseInfoView.swift
//  housetainer-ios
//
//  Created by 김수아 on 2/13/24.
//

import Foundation
import UIKit
import SnapKit
import SwiftUI

final class CreateHouseInfoView: UIView{
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        define()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layout()
    }
    
    // MARK: - UI Properties
    private let scrollView = UIScrollView()
    private let scrollContainer = {
        let view = UIView()
        view.layoutMargins = UIEdgeInsets(top: 28, left: 20, bottom: 10, right: 20)
        return view
    }()
    
    private let spaceCategoryTextInput = {
        let textInput = TextInput()
        textInput.layer.borderColor = Color.gray200.cgColor
        textInput.layer.borderWidth = 1
        textInput.layer.cornerRadius = 4
        textInput.contentEdgeInsets = .init(top: 14, left: 12, bottom: 14, right: 12)
        textInput.underlineWidth = 0
        textInput.placeholder = "선택하세요"
        textInput.rightViewMode = .always
        textInput.rightView = {
            let imageView = UIImageView()
            imageView.image = Icon.arrowDown
            return imageView
        }()
        return textInput
    }()
    private lazy var spaceCategoryInputLayout = {
        let inputLayout = InputLayout()
        inputLayout.spacing = 16
        inputLayout.title = "공간 카테고리"
        inputLayout.inputViewBuilder = { [weak self] in
            guard let self else{ return UIView() }
            return spaceCategoryTextInput
        }
        return inputLayout
    }()
    
    private lazy var locationStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        view.distribution = .fillEqually
        view.spacing = 13
        view.addArrangedSubview(self.locationInKoreaView)
        view.addArrangedSubview(self.locationInForeign)
        return view
    }()
    private lazy var locationInKoreaView = {
        let view = CategoryView()
        view.layoutMargins = UIEdgeInsets(top: 11, left: 22, bottom: 11, right: 22)
        view.title = "대한민국"
        view.addTarget(self, action: #selector(didTapLocationInKorea), for: .touchUpInside)
        return view
    }()
    private lazy var locationInForeign = {
        let view = CategoryView()
        view.layoutMargins = UIEdgeInsets(top: 11, left: 22, bottom: 11, right: 22)
        view.title = "해외"
        view.addTarget(self, action: #selector(didTapLocationInForeign), for: .touchUpInside)
        return view
    }()
    private lazy var locationInputLayout = {
        let inputLayout = InputLayout()
        inputLayout.spacing = 16
        inputLayout.title = "지역 선택"
        inputLayout.inputViewBuilder = { [weak self] in
            guard let self else{ return UIView() }
            return locationStackView
        }
        return inputLayout
    }()
    
    
    private let address1TextInput = {
        let textInput = TextInput()
        textInput.layer.borderColor = Color.gray200.cgColor
        textInput.layer.borderWidth = 1
        textInput.layer.cornerRadius = 4
        textInput.contentEdgeInsets = .init(top: 14, left: 12, bottom: 14, right: 12)
        textInput.underlineWidth = 0
        textInput.placeholder = "시/도"
        textInput.rightViewMode = .always
        textInput.rightView = {
            let imageView = UIImageView()
            imageView.image = Icon.arrowDown
            return imageView
        }()
        return textInput
    }()
    private lazy var address1InputLayout = {
        let inputLayout = InputLayout()
        inputLayout.inputViewBuilder = { [weak self] in
            guard let self else{ return UIView() }
            return address1TextInput
        }
        return inputLayout
    }()
    
    private let address2TextInput = {
        let textInput = TextInput()
        textInput.layer.borderColor = Color.gray200.cgColor
        textInput.layer.borderWidth = 1
        textInput.layer.cornerRadius = 4
        textInput.contentEdgeInsets = .init(top: 14, left: 12, bottom: 14, right: 12)
        textInput.underlineWidth = 0
        textInput.placeholder = "군/구"
        textInput.rightViewMode = .always
        textInput.rightView = {
            let imageView = UIImageView()
            imageView.image = Icon.arrowDown
            return imageView
        }()
        return textInput
    }()
    private lazy var address2InputLayout = {
        let inputLayout = InputLayout()
        inputLayout.inputViewBuilder = { [weak self] in
            guard let self else{ return UIView() }
            return address2TextInput
        }
        return inputLayout
    }()
    
    private let shortDescriptionTextInput = {
        let textInput = MultiTextInput()
        textInput.placeholder = """
        10글자 이상 입력해주세요
        """
        textInput.snp.makeConstraints{
            $0.height.greaterThanOrEqualTo(63)
        }
        return textInput
    }()
    private lazy var shortDescriptionInputLayout = {
        let inputLayout = InputLayout()
        inputLayout.spacing = 16
        inputLayout.title = "집 한 줄 소개"
        inputLayout.inputViewBuilder = { [weak self] in
            guard let self else{ return UIView() }
            return shortDescriptionTextInput
        }
        return inputLayout
    }()
    
    private let photoInputLayout = {
        let inputLayout = InputLayout()
        inputLayout.title = "대표 사진"
        inputLayout.spacing = 7
        inputLayout.inputViewBuilder = {
            let slider = HorizontalPhotoSlider()
            slider.snp.makeConstraints{
                $0.height.equalTo(85)
            }
            return slider
        }
        return inputLayout
    }()
    
    private let descriptionTextInput = {
        let textInput = MultiTextInput()
        textInput.placeholder = """
        집밥의 매력과 정겨움, 유쾌함을 나누려는 오브리쿡 하우스
        """
        textInput.snp.makeConstraints{
            $0.height.greaterThanOrEqualTo(128)
        }
        return textInput
    }()
    private lazy var descriptionInputLayout = {
        let inputLayout = InputLayout()
        inputLayout.spacing = 16
        inputLayout.title = "집 소개 글"
        inputLayout.inputViewBuilder = { [weak self] in
            guard let self else{ return UIView() }
            return descriptionTextInput
        }
        return inputLayout
    }()
    
    // MARK: - Private
}

private extension CreateHouseInfoView{
    func setupUI(){
        addSubview(scrollView)
        scrollView.addSubview(scrollContainer)
        scrollContainer.addSubview(spaceCategoryInputLayout)
        scrollContainer.addSubview(locationInputLayout)
        scrollContainer.addSubview(address1InputLayout)
        scrollContainer.addSubview(address2InputLayout)
        scrollContainer.addSubview(shortDescriptionInputLayout)
        scrollContainer.addSubview(photoInputLayout)
        scrollContainer.addSubview(descriptionInputLayout)
    }
    
    func define(){
        scrollView.snp.makeConstraints{
            $0.directionalEdges.equalToSuperview()
        }
        
        scrollContainer.snp.makeConstraints{
            $0.directionalEdges.equalToSuperview()
            $0.width.equalToSuperview()
        }
        
        spaceCategoryInputLayout.snp.makeConstraints{
            $0.top.equalTo(scrollContainer.snp.topMargin)
            $0.leading.equalTo(scrollContainer.snp.leadingMargin)
            $0.trailing.equalTo(scrollContainer.snp.trailingMargin)
        }
        
        locationInputLayout.snp.makeConstraints{
            $0.top.equalTo(spaceCategoryInputLayout.snp.bottom).offset(32)
            $0.leading.equalTo(scrollContainer.snp.leadingMargin)
            $0.trailing.equalTo(scrollContainer.snp.trailingMargin)
        }
        
        address1InputLayout.snp.makeConstraints{
            $0.top.equalTo(locationInputLayout.snp.bottom).offset(8)
            $0.leading.equalTo(scrollContainer.snp.leadingMargin)
            $0.trailing.equalTo(scrollContainer.snp.trailingMargin)
        }
        
        address2InputLayout.snp.makeConstraints{
            $0.top.equalTo(address1InputLayout.snp.bottom).offset(8)
            $0.leading.equalTo(scrollContainer.snp.leadingMargin)
            $0.trailing.equalTo(scrollContainer.snp.trailingMargin)
        }
        
        shortDescriptionInputLayout.snp.makeConstraints{
            $0.top.equalTo(address2InputLayout.snp.bottom).offset(32)
            $0.leading.equalTo(scrollContainer.snp.leadingMargin)
            $0.trailing.equalTo(scrollContainer.snp.trailingMargin)
        }
        
        photoInputLayout.snp.makeConstraints{
            $0.top.equalTo(shortDescriptionInputLayout.snp.bottom).offset(32)
            $0.leading.equalTo(scrollContainer.snp.leadingMargin)
            $0.trailing.equalTo(scrollContainer.snp.trailingMargin)
        }
        
        descriptionInputLayout.snp.makeConstraints{
            $0.top.equalTo(photoInputLayout.snp.bottom).offset(32)
            $0.leading.equalTo(scrollContainer.snp.leadingMargin)
            $0.trailing.equalTo(scrollContainer.snp.trailingMargin)
            $0.bottom.equalToSuperview()
        }
    }
    
    func layout(){
        
    }
    
    @objc func didTapLocationInKorea(){
        locationStackView.subviews.forEach{
            ($0 as? UIControl)?.isSelected = ($0 === locationInKoreaView)
        }
    }
    
    @objc func didTapLocationInForeign(){
        locationStackView.subviews.forEach{
            ($0 as? UIControl)?.isSelected = ($0 === locationInForeign)
        }
    }
}

struct CreateHouseInfoView_Preview: PreviewProvider{
    static var previews: some View{
        ViewPreview{
            let view = CreateHouseInfoView()
            return view
        }
    }
}
