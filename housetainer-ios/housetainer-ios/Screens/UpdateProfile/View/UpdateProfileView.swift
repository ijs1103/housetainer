//
//  UpdateProfileView.swift
//  housetainer-ios
//
//  Created by 김수아 on 1/15/24.
//

import Foundation
import UIKit
import SnapKit
import SwiftUI

final class UpdateProfileView: UIView{
    var didTapProfileContainer: (() -> Void)?
    var didChangeGender: ((Gender?) -> Void)?
    var didChangeBirthday: ((Date) -> Void)?
    var didTapChangeNickname: (() -> Void)?
    var didTapLogout: (() -> Void)?
    var didTapWithdrawal: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        define()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit{
        NotificationCenter.default.removeObserver(self)
    }
    
    func updateUser(_ user: UserProfile){
        profileImageView.setImage(user.profileRef, placeholder: Icon.nofaceLarge)
        userLevelValueLabel.attributedText = NSAttributedString{
            NSAttributedString(string: user.memberType.description)
            
            if user.memberType.isHouseTainer{
                NSAttributedString.spacing(width: 4)
                NSAttributedString.image(Icon.housetainer!)
            }
        }
        userEmailValueLabel.text = user.email
        if nicknameTextInput.text != user.username{
            nicknameTextInput.text = user.username
        }
        femaleGenderCategoryView.isSelected = user.gender == .female
        maleGenderCategoryView.isSelected = user.gender == .male
        privateGenderCategoryView.isSelected = user.gender == .none
        if birthInput.text != user.birthday?.format(with: "yyMMdd"){
            birthInput.text = user.birthday?.format(with: "yyMMdd")
        }
        birthPicker.date = user.birthday.ifNil(then: Date())
        changeNicknameButton.isEnabled = false
        //changeNicknameButton.isEnabled = user.canUpdateNickname
    }
    
    // MARK: - UI Properties
    private let scrollView = {
        let scrollView = UIScrollView()
        scrollView.keyboardDismissMode = .interactiveWithAccessory
        return scrollView
    }()
    private let scrollContainer = {
        let view = UIView()
        view.layoutMargins = UIEdgeInsets(top: 20, left: 20, bottom: 46, right: 20)
        return view
    }()
    private lazy var profileContainer = {
        let view = UIView()
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapProfileContainerAction)))
        return view
    }()
    private let profileImageView = {
        let imageView = HTImageView(frame: .zero)
        imageView.layer.masksToBounds = true
        imageView.didLayout = { [weak imageView] in
            guard let imageView else{ return }
            imageView.layer.cornerRadius = imageView.frame.height / 2
        }
        return imageView
    }()
    private let profileInfoLabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = Typo.Body3()
        label.textColor = Color.gray600
        label.textAlignment = .center
        label.text = """
        나의 라이프 스타일을 표현할 수 있는
        사진을 올려주세요.
        """
        return label
    }()
    private let editProfileImageView = {
        let imageView = UIImageView()
        imageView.image = Icon.cameraSmall
        return imageView
    }()
    private let readOnlyContainer = {
        let view = UIView()
        view.layoutMargins = UIEdgeInsets(top: 24, left: 24, bottom: 24, right: 24)
        view.backgroundColor = Color.gray100
        view.layer.cornerRadius = 12
        view.layer.masksToBounds = true
        return view
    }()
    private let userLevelTitleLabel = {
        let label = UILabel()
        label.font = Typo.Title5()
        label.textColor = Color.black
        label.text = "회원 등급"
        return label
    }()
    private let userEmailTitleLabel = {
        let label = UILabel()
        label.font = Typo.Title5()
        label.textColor = Color.black
        label.text = "아이디"
        return label
    }()
    private let userLevelValueLabel = {
        let label = UILabel()
        label.font = Typo.Body3()
        label.textColor = Color.black
        label.text = ""
        label.numberOfLines = 0
        return label
    }()
    private let userEmailValueLabel = {
        let label = UILabel()
        label.font = Typo.Body3()
        label.textColor = Color.gray600
        label.text = ""
        label.numberOfLines = 0
        return label
    }()
    private lazy var nicknameTextInput = {
        let textInput = TextInput()
        textInput.placeholder = "닉네임"
        textInput.underlineWidth = 0
        textInput.isEnabled = false
        return textInput
    }()
    private lazy var changeNicknameButton = {
        let button = UIButton()
        button.titleLabel?.font = Typo.Body3()
        button.setTitleColor(Color.gray500, for: .disabled)
        button.setTitleColor(Color.white, for: .normal)
        button.setTitle("변경", for: .normal)
        button.setBackgroundColor(Color.gray200, for: .disabled)
        button.setBackgroundColor(Color.purple400, for: .normal)
        button.layer.cornerRadius = 4
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(didTapChangeNicknameAction), for: .touchUpInside)
        button.isEnabled = false
        return button
    }()
    private lazy var nicknameInputLayout = {
        let inputLayout = InputLayout()
        inputLayout.title = "닉네임"
        inputLayout.underlineWidth = 1
        inputLayout.inputViewBuilder = { [weak self] in
            let view = UIView()
            guard let self else{ return view }
            view.addSubview(nicknameTextInput)
            view.addSubview(changeNicknameButton)
            nicknameTextInput.snp.makeConstraints{
                $0.leading.directionalVerticalEdges.equalToSuperview()
                $0.trailing.equalTo(self.changeNicknameButton.snp.leading)
            }
            changeNicknameButton.snp.makeConstraints {
                $0.trailing.equalToSuperview()
                $0.directionalVerticalEdges.equalToSuperview().inset(6)
                $0.centerY.equalToSuperview()
                $0.width.equalTo(56)
            }
            return view
        }
        return inputLayout
    }()
    private lazy var maleGenderCategoryView = {
        let categoryView = CategoryView()
        categoryView.title = "남"
        categoryView.addTarget(self, action: #selector(didTapMaleGender), for: .touchUpInside)
        return categoryView
    }()
    private lazy var femaleGenderCategoryView = {
        let categoryView = CategoryView()
        categoryView.title = "여"
        categoryView.addTarget(self, action: #selector(didTapFemaleGender), for: .touchUpInside)
        return categoryView
    }()
    private lazy var privateGenderCategoryView = {
        let categoryView = CategoryView()
        categoryView.title = "공개 안함"
        categoryView.addTarget(self, action: #selector(didTapPrivateGender), for: .touchUpInside)
        return categoryView
    }()
    private lazy var genderInputLayout = {
        let inputLayout = InputLayout()
        inputLayout.title = "성별"
        inputLayout.inputViewBuilder = { [weak self] in
            let stack = UIStackView()
            guard let self else{ return stack }
            stack.axis = .horizontal
            stack.spacing = 13
            stack.distribution = .fillEqually
            stack.addArrangedSubview(maleGenderCategoryView)
            stack.addArrangedSubview(femaleGenderCategoryView)
            stack.addArrangedSubview(privateGenderCategoryView)
            return stack
        }
        return inputLayout
    }()
    private lazy var birthPicker = {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.maximumDate = Date()
        datePicker.addTarget(self, action: #selector(didChangeBirthdayAction), for: .valueChanged)
        return datePicker
    }()
    private lazy var birthInput = {
        let textInput = TextInput()
        textInput.inputView = birthPicker
        return textInput
    }()
    private lazy var birthLayout = {
        let inputLayout = InputLayout()
        inputLayout.title = "생년월일"
        inputLayout.inputViewBuilder = { [weak self] in
            guard let self else{ return UIView() }
            return birthInput
        }
        return inputLayout
    }()
    private lazy var logoutButton = {
        let button = UIButton()
        button.titleLabel?.font = Typo.Body3Medium()
        button.setTitle("로그아웃", for: .normal)
        button.setTitleColor(Color.reddishPurple600, for: .normal)
        button.layer.borderWidth = 1
        button.layer.borderColor = Color.reddishPurple600.cgColor
        button.layer.cornerRadius = 8
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(didTapLogoutButtonAction), for: .touchUpInside)
        return button
    }()
    private lazy var withdrawalButton = {
        let button = UIButton()
        button.titleLabel?.font = Typo.Body3Medium()
        button.setAttributedTitle(NSAttributedString(string: "탈퇴하기", attributes: [
            .underlineColor: Color.gray600,
            .underlineStyle: NSUnderlineStyle.single.rawValue
        ]), for: .normal)
        button.setTitleColor(Color.gray600, for: .normal)
        button.addTarget(self, action: #selector(didTapWithdrawalButtonAction), for: .touchUpInside)
        return button
    }()
    
    // MAKR: - Private
}

private extension UpdateProfileView{
    func setupUI(){
        backgroundColor = Color.white
        
        addSubview(scrollView)
        scrollView.addSubview(scrollContainer)
        scrollContainer.addSubview(profileContainer)
        profileContainer.addSubview(profileImageView)
        profileContainer.addSubview(editProfileImageView)
        scrollContainer.addSubview(profileInfoLabel)
        scrollContainer.addSubview(readOnlyContainer)
        readOnlyContainer.addSubview(userLevelTitleLabel)
        readOnlyContainer.addSubview(userEmailTitleLabel)
        readOnlyContainer.addSubview(userLevelValueLabel)
        readOnlyContainer.addSubview(userEmailValueLabel)
        scrollContainer.addSubview(nicknameInputLayout)
        scrollContainer.addSubview(genderInputLayout)
        scrollContainer.addSubview(birthLayout)
        scrollContainer.addSubview(logoutButton)
        scrollContainer.addSubview(withdrawalButton)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShowNotification(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHideNotification(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func define(){
        scrollView.snp.makeConstraints{
            $0.directionalEdges.equalToSuperview()
        }
        
        scrollContainer.snp.makeConstraints{
            $0.directionalEdges.equalToSuperview()
            $0.width.equalToSuperview()
        }
        
        profileContainer.snp.makeConstraints{
            $0.width.height.equalTo(120)
            $0.centerX.equalToSuperview()
            $0.top.equalTo(scrollContainer.snp.topMargin)
            $0.leading.greaterThanOrEqualTo(scrollContainer.snp.leadingMargin)
            $0.trailing.lessThanOrEqualTo(scrollContainer.snp.trailingMargin)
        }
        
        profileImageView.snp.makeConstraints{
            $0.directionalEdges.equalToSuperview()
        }
        
        editProfileImageView.snp.makeConstraints {
            $0.trailing.bottom.equalToSuperview()
        }
        
        profileInfoLabel.snp.makeConstraints{
            $0.top.equalTo(profileImageView.snp.bottom).offset(14)
            $0.leading.greaterThanOrEqualTo(scrollContainer.snp.leadingMargin).offset(70)
            $0.trailing.lessThanOrEqualTo(scrollContainer.snp.trailingMargin).offset(-70)
        }
        
        readOnlyContainer.snp.makeConstraints{
            $0.top.equalTo(profileInfoLabel.snp.bottom).offset(26)
            $0.leading.equalTo(scrollContainer.snp.leadingMargin)
            $0.trailing.equalTo(scrollContainer.snp.trailingMargin)
        }
        
        userLevelTitleLabel.snp.makeConstraints{
            $0.top.equalTo(readOnlyContainer.snp.topMargin)
            $0.leading.equalTo(readOnlyContainer.snp.leadingMargin)
        }
        
        userEmailTitleLabel.snp.makeConstraints{
            $0.top.equalTo(userLevelTitleLabel.snp.bottom).offset(9)
            $0.leading.equalTo(readOnlyContainer.snp.leadingMargin)
            $0.bottom.equalTo(readOnlyContainer.snp.bottomMargin)
        }
        
        userLevelValueLabel.snp.makeConstraints{
            $0.top.equalTo(readOnlyContainer.snp.topMargin)
            $0.leading.equalTo(userLevelTitleLabel.snp.trailing).offset(59)
            $0.leading.equalTo(userEmailTitleLabel.snp.trailing).offset(59)
            $0.trailing.lessThanOrEqualToSuperview().offset(-24)
        }
        userLevelValueLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        
        userEmailValueLabel.snp.makeConstraints{
            $0.top.equalTo(userEmailTitleLabel.snp.top).offset(2)
            $0.leading.equalTo(userLevelTitleLabel.snp.trailing).offset(59)
            $0.leading.equalTo(userEmailTitleLabel.snp.trailing).offset(59)
            $0.bottom.equalTo(readOnlyContainer.snp.bottomMargin)
            $0.trailing.lessThanOrEqualToSuperview().offset(-24)
        }
        userEmailValueLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        
        nicknameInputLayout.snp.makeConstraints{
            $0.top.equalTo(readOnlyContainer.snp.bottom).offset(40)
            $0.leading.equalTo(scrollContainer.snp.leadingMargin)
            $0.trailing.equalTo(scrollContainer.snp.trailingMargin)
        }
        
        genderInputLayout.snp.makeConstraints{
            $0.top.equalTo(nicknameInputLayout.snp.bottom).offset(32)
            $0.leading.equalTo(scrollContainer.snp.leadingMargin)
            $0.trailing.equalTo(scrollContainer.snp.trailingMargin)
        }
        
        birthLayout.snp.makeConstraints{
            $0.top.equalTo(genderInputLayout.snp.bottom).offset(33)
            $0.leading.equalTo(scrollContainer.snp.leadingMargin)
            $0.trailing.equalTo(scrollContainer.snp.trailingMargin)
        }
        
        logoutButton.snp.makeConstraints{
            $0.top.equalTo(birthLayout.snp.bottom).offset(60)
            $0.leading.equalTo(scrollContainer.snp.leadingMargin)
            $0.trailing.equalTo(scrollContainer.snp.trailingMargin)
            $0.height.equalTo(41)
        }
        
        withdrawalButton.snp.makeConstraints{
            $0.top.equalTo(logoutButton.snp.bottom).offset(8)
            $0.leading.equalTo(scrollContainer.snp.leadingMargin)
            $0.trailing.equalTo(scrollContainer.snp.trailingMargin)
            $0.bottom.equalTo(scrollContainer.snp.bottomMargin)
            $0.height.equalTo(41)
        }
    }
    
    @objc func didTapProfileContainerAction(){
        didTapProfileContainer?()
    }
    
    @objc func didChangeBirthdayAction(){
        didChangeBirthday?(birthPicker.date)
    }
    
    @objc func didTapChangeNicknameAction(){
        didTapChangeNickname?()
    }
    
    @objc func didTapMaleGender(){
        [maleGenderCategoryView, femaleGenderCategoryView, privateGenderCategoryView].forEach{
            $0.isSelected = maleGenderCategoryView == $0
        }
        didChangeGender?(.male)
    }
    
    @objc func didTapFemaleGender(){
        [maleGenderCategoryView, femaleGenderCategoryView, privateGenderCategoryView].forEach{
            $0.isSelected = femaleGenderCategoryView == $0
        }
        didChangeGender?(.female)
    }
    
    @objc func didTapPrivateGender(){
        [maleGenderCategoryView, femaleGenderCategoryView, privateGenderCategoryView].forEach{
            $0.isSelected = privateGenderCategoryView == $0
        }
        didChangeGender?(.none)
    }
    
    @objc func keyboardWillShowNotification(_ notification: NSNotification){
        guard
            let userInfo = notification.userInfo,
            let endFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect
        else{ return }
        scrollView.contentInset.bottom = endFrame.height - self.safeAreaInsets.bottom
    }
    
    @objc func keyboardWillHideNotification(_ notification: NSNotification){
        scrollView.contentInset.bottom = 0
    }
    
    @objc func didTapLogoutButtonAction(){
        didTapLogout?()
    }
    
    @objc func didTapWithdrawalButtonAction(){
        didTapWithdrawal?()
    }
}

struct UpdateProfileView_Previews: PreviewProvider{
    static var previews: some View{
        ViewPreview{
            let view = UpdateProfileView()
            return view
        }
    }
}
