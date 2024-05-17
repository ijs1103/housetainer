//
//  CreateSocialCalendarView.swift
//  housetainer-ios
//
//  Created by 김수아 on 1/14/24.
//

import Foundation
import UIKit
import SwiftUI
import SnapKit
import Photos

final class CreateSocialCalendarView: UIView{
    var didChangeTitle: ((String) -> Void)?
    var didTapDate: (() -> Void)?
    var didTapNew: (() -> Void)?
    var didTapDelete: (() -> Void)?
    var didTapScheduleType: ((ScheduleType) -> Void)?
    var didChangeLink: ((String) -> Void)?
    var didChangeDescription: ((String) -> Void)?
    
    init(){
        super.init(frame: .zero)
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
    
    func updateCreateSocialCalendar(_ createSocialCalendar: CreateSocialCalendar){
        if titleTextInput.text != createSocialCalendar.title{
            titleTextInput.text = createSocialCalendar.title
        }
        
        dateField.setTitle((createSocialCalendar.date?.format(with: "yyyy.MM.dd (E)")).ifNil(then: "날짜를 입력해주세요"), for: .normal)
        
        categorySpaceView.isSelected = createSocialCalendar.scheduleType == .host
        categoryEventView.isSelected = createSocialCalendar.scheduleType == .attendant
        
        photoSlider.items = createSocialCalendar.imageRefs.map{ imageRef in
            HorizontalPhotoSlider.Item(reference: imageRef, isMain: true)
        }
        
        if linkTextInput.text != createSocialCalendar.link{
            linkTextInput.text = createSocialCalendar.link
        }
        
        if descriptionTextInput.text != createSocialCalendar.description{
            descriptionTextInput.text = createSocialCalendar.description
        }
    }
    
    // MARK: - UI Properties
    private let scrollView = {
        let scrollView = UIScrollView()
        scrollView.keyboardDismissMode = .interactiveWithAccessory
        return scrollView
    }()
    private let scrollContainer = {
        let view = UIView()
        view.layoutMargins = UIEdgeInsets(top: 20, left: 20, bottom: 97, right: 20)
        return view
    }()
    private let vStack = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .leading
        stack.spacing = 40
        return stack
    }()
    private let titleLabel = {
        let label = UILabel()
        label.font = Typo.Heading1()
        label.textColor = Color.gray900
        label.numberOfLines = 0
        label.text = """
        참석하는 스케줄로
        소통하세요!
        """
        return label
    }()
    private lazy var titleTextInput = {
        let textField = TextInput()
        textField.placeholder = "제목을 입력해주세요"
        textField.isCounterHidden = false
        textField.maxLength = 16
        textField.addTarget(self, action: #selector(didChangeTitleAction), for: .editingChanged)
        return textField
    }()
    private lazy var titleInputLayout = {
        let inputLayout = InputLayout()
        inputLayout.title = "제목"
        inputLayout.inputViewBuilder = { [weak self] in
            guard let self else{ return UIView() }
            return titleTextInput
        }
        return inputLayout
    }()
    private lazy var dateField = {
        let button = UIButton()
        button.contentEdgeInsets = .init(top: 12, left: 16, bottom: 12, right: 16)
        button.titleLabel?.font = Typo.Body1()
        button.setTitle("날짜를 입력해주세요", for: .normal)
        button.setTitleColor(Color.gray900, for: .normal)
        button.addTarget(self, action: #selector(didBeginEditingDate), for: .touchUpInside)
        button.layer.borderWidth = 1
        button.layer.borderColor = Color.gray150.cgColor
        button.layer.cornerRadius = 12
        button.layer.masksToBounds = true
        return button
    }()
    private lazy var dateInputLayout = {
        let inputLayout = InputLayout()
        inputLayout.title = "내가 참석하는 날짜"
        inputLayout.inputViewBuilder = { [weak self] in
            guard let self else{ return UIView() }
            return dateField
        }
        return inputLayout
    }()
    private lazy var categorySpaceView = {
        let view = HTCategoryView()
        view.title = "I am host"
        view.desc = "내가 주최해요"
        view.addTarget(self, action: #selector(didTapHost), for: .touchUpInside)
        return view
    }()
    private lazy var categoryEventView = {
        let view = HTCategoryView()
        view.title = "I am attendant"
        view.desc = "참여자로 가요"
        view.addTarget(self, action: #selector(didTapAttendant), for: .touchUpInside)
        return view
    }()
    private let categoryDescriptionLabel = {
        let label = UILabel()
        label.font = Typo.Body2()
        label.textColor = Color.gray600
        label.text = """
        공연, 전시, 클래스, 팝업, 여행 등
        """
        return label
    }()
    private lazy var categoryInputLayout = {
        let inputLayout = InputLayout()
        inputLayout.title = "스케줄 유형"
        inputLayout.spacing = 4
        inputLayout.inputViewBuilder = { [weak self] in
            guard let self else{ return UIView() }
            let verticalStack = UIStackView()
            verticalStack.axis = .vertical
            verticalStack.spacing = 16
            
            let horizontlalStack = UIStackView()
            horizontlalStack.axis = .horizontal
            horizontlalStack.distribution = .fillEqually
            horizontlalStack.spacing = 12
            horizontlalStack.addArrangedSubview(categorySpaceView)
            horizontlalStack.addArrangedSubview(categoryEventView)
            
            verticalStack.addArrangedSubview(categoryDescriptionLabel)
            verticalStack.addArrangedSubview(horizontlalStack)
            return verticalStack
        }
        return inputLayout
    }()
    private lazy var photoSlider = {
        let slider = HorizontalPhotoSlider()
        slider.didTapNew = { [weak self] in
            guard let self else{ return }
            didTapNew?()
        }
        slider.didTapDelete = { [weak self] index in
            guard let self else{ return }
            didTapDelete?()
        }
        return slider
    }()
    private lazy var photoInputLayout = {
        let inputLayout = InputLayout()
        inputLayout.title = "대표 사진"
        inputLayout.spacing = 4
        inputLayout.inputViewBuilder = { [weak self] in
            guard let self else{ return UIView() }
            return photoSlider
        }
        return inputLayout
    }()
    private lazy var linkTextInput = {
        let textField = TextInput()
        textField.placeholder = "https://www.example.com"
        textField.addTarget(self, action: #selector(didChangeLinkAction), for: .editingChanged)
        return textField
    }()
    private lazy var linkInputLayout = {
        let inputLayout = InputLayout()
        let title = NSMutableAttributedString()
        title.append(NSAttributedString(string: "신청 및 관련 링크 "))
        title.append(NSAttributedString(string: "(선택)", attributes: [
            .foregroundColor: Color.gray400,
            .font: Typo.Body3()
        ]))
        inputLayout.attributedTitle = title
        inputLayout.inputViewBuilder = { [weak self] in
            guard let self else{ return UIView() }
            return linkTextInput
        }
        return inputLayout
    }()
    private lazy var descriptionTextInput = {
        let textField = MultiTextInput()
        textField.placeholder = """
        어떤 일정인지 소개해주세요!
        이런 내용을 포함하면 좋아요:)
        - 일정의 성격
        - 참석 이유
        - 만나면 하고 싶은 이야기
        - 함께 하는 사람
        """
        textField.snp.makeConstraints{
            $0.height.greaterThanOrEqualTo(360)
        }
        textField.didChangeText = { [weak self] text in
            guard let self else{ return }
            didChangeDescription?(text)
        }
        return textField
    }()
    private lazy var descriptionInputLayout = {
        let inputLayout = InputLayout()
        inputLayout.title = "소개"
        inputLayout.inputViewBuilder = { [weak self] in
            guard let self else{ return UIView() }
            return descriptionTextInput
        }
        return inputLayout
    }()
}

private extension CreateSocialCalendarView{
    func setupUI(){
        backgroundColor = Color.white
        
        addSubview(scrollView)
        scrollView.addSubview(scrollContainer)
        scrollContainer.addSubview(vStack)
        vStack.addArrangedSubview(titleLabel)
        vStack.addArrangedSubview(titleInputLayout)
        vStack.addArrangedSubview(categoryInputLayout)
        vStack.addArrangedSubview(dateInputLayout)
        vStack.addArrangedSubview(photoInputLayout)
        vStack.addArrangedSubview(descriptionInputLayout)
        vStack.addArrangedSubview(linkInputLayout)
        
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
        vStack.snp.makeConstraints{
            $0.directionalEdges.equalTo(scrollContainer.snp.directionalMargins)
        }
        titleInputLayout.snp.makeConstraints{
            $0.width.equalToSuperview()
        }
        categoryInputLayout.snp.makeConstraints{
            $0.width.equalToSuperview()
        }
        photoInputLayout.snp.makeConstraints{
            $0.width.equalToSuperview()
        }
        linkInputLayout.snp.makeConstraints{
            $0.width.equalToSuperview()
        }
        descriptionInputLayout.snp.makeConstraints{
            $0.width.equalToSuperview()
        }
    }
    
    @objc func didChangeLinkAction(){
        didChangeLink?(linkTextInput.text.ifNil(then: "").trimmingCharacters(in: .whitespaces))
    }
    
    @objc func didChangeTitleAction(){
        didChangeTitle?(titleTextInput.text.ifNil(then: ""))
    }
    
    @objc func didTapHost(){
        categorySpaceView.isSelected = true
        categoryEventView.isSelected = false
        
        didTapScheduleType?(.host)
    }
    
    @objc func didTapAttendant(){
        categorySpaceView.isSelected = false
        categoryEventView.isSelected = true
        
        didTapScheduleType?(.attendant)
    }
    
    @objc func didBeginEditingDate(){
        dateField.resignFirstResponder()
        didTapDate?()
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
}

struct CreateSocialCalendarView_Previews: PreviewProvider{
    static var previews: some View{
        ViewPreview{
            let view = CreateSocialCalendarView()
            return view
        }
    }
}
