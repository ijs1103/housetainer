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
    var didTapDone: ((EventToUpdate?) -> Void)?
    var didTapScheduleType: ((ScheduleType) -> Void)?
    var didChangeLink: ((String) -> Void)?
    var didChangeDescription: ((String) -> Void)?
    
    init(eventId: String? = nil) {
        self.eventId = eventId
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
        
        dateField.text = createSocialCalendar.date?.format(with: "yyyy.MM.dd (E)")
        
        categorySpaceView.isSelected = createSocialCalendar.scheduleType == .공간
        categoryEventView.isSelected = createSocialCalendar.scheduleType == .행사
        
        photoSlider.items = createSocialCalendar.imageRefs.map{ imageRef in
            HorizontalPhotoSlider.Item(reference: imageRef, isMain: true)
        }
        
        if linkTextInput.text != createSocialCalendar.link{
            linkTextInput.text = createSocialCalendar.link
        }
        
        if descriptionTextInput.text != createSocialCalendar.description{
            descriptionTextInput.text = createSocialCalendar.description
        }
        
        doneButton.isEnabled = createSocialCalendar.canUpdate
    }
    
    // MARK: - UI Properties
    private let scrollView = {
        let scrollView = UIScrollView()
        scrollView.keyboardDismissMode = .interactiveWithAccessory
        return scrollView
    }()
    private let scrollContainer = {
        let view = UIView()
        view.layoutMargins = UIEdgeInsets(top: 28, left: 20, bottom: 20, right: 20)
        return view
    }()
    private let vStack = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .leading
        stack.spacing = 32
        return stack
    }()
    private lazy var titleTextInput = {
        let textField = TextInput()
        textField.placeholder = "제목을 입력해주세요"
        textField.isCounterHidden = false
        textField.maxLength = 10
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
        let textField = HTTextField()
        textField.placeholder = "날짜를 입력해주세요"
        textField.rightView = UIImageView(image: Icon.dateSmall)
        textField.rightViewMode = .always
        textField.font = Typo.Body2()
        textField.textColor = Color.black
        textField.rightViewInset = .init(top: 0, left: 6, bottom: 0, right: -6)
        textField.isSelectionEnabled = false
        textField.addTarget(self, action: #selector(didBeginEditingDate), for: .editingDidBegin)
        return textField
    }()
    private lazy var dateInputLayout = {
        let inputLayout = InputLayout()
        inputLayout.title = "날짜"
        inputLayout.inputViewBuilder = { [weak self] in
            guard let self else{ return UIView() }
            return dateField
        }
        return inputLayout
    }()
    private lazy var categorySpaceView = {
        let view = CategoryView()
        view.title = "공간"
        view.desc = "맛집, 여행, 쇼룸 등"
        view.addTarget(self, action: #selector(didTapSpace), for: .touchUpInside)
        return view
    }()
    private lazy var categoryEventView = {
        let view = CategoryView()
        view.title = "행사"
        view.desc = "전시, 공연, 마켓 등"
        view.addTarget(self, action: #selector(didTapEvent), for: .touchUpInside)
        return view
    }()
    private lazy var categoryInputLayout = {
        let inputLayout = InputLayout()
        inputLayout.title = "내가 가려는"
        inputLayout.inputViewBuilder = {
            let view = UIStackView()
            view.axis = .horizontal
            view.distribution = .fillEqually
            view.spacing = 13
            view.addArrangedSubview(self.categorySpaceView)
            view.addArrangedSubview(self.categoryEventView)
            return view
        }
        return inputLayout
    }()
    private lazy var photoSlider = {
        let slider = HorizontalPhotoSlider()
        slider.snp.makeConstraints{
            $0.height.equalTo(85)
        }
        slider.didTapNew = { [weak self] in
            guard let self else{ return }
            didTapNew?()
        }
        return slider
    }()
    private lazy var photoInputLayout = {
        let inputLayout = InputLayout()
        inputLayout.title = "대표 사진"
        inputLayout.spacing = 7
        inputLayout.inputViewBuilder = { [weak self] in
            guard let self else{ return UIView() }
            return photoSlider
        }
        return inputLayout
    }()
    private lazy var linkTextInput = {
        let textField = TextInput()
        textField.placeholder = "https"
        textField.addTarget(self, action: #selector(didChangeLinkAction), for: .editingChanged)
        return textField
    }()
    private lazy var linkInputLayout = {
        let inputLayout = InputLayout()
        let title = NSMutableAttributedString()
        title.append(NSAttributedString(string: "링크 "))
        title.append(NSAttributedString(string: "(선택)", attributes: [
            .foregroundColor: Color.gray400,
            .font: Typo.Body4()
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
        이런 내용을 포함하면 좋아요.
        - 행사/공간 성격
        - 참석 이유
        - 만나면 하고싶은 이야기
        - 함께 하는 사람
        """
        textField.snp.makeConstraints{
            $0.height.greaterThanOrEqualTo(192)
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
        inputLayout.spacing = 10
        inputLayout.inputViewBuilder = { [weak self] in
            guard let self else{ return UIView() }
            return descriptionTextInput
        }
        return inputLayout
    }()
    private lazy var doneButton = {
        let button = UIButton()
        button.titleLabel?.font = Typo.Title4()
        button.setTitleColor(Color.gray500, for: .disabled)
        button.setTitleColor(Color.white, for: .normal)
        button.setTitle("작성 완료", for: .normal)
        button.setBackgroundColor(Color.gray200, for: .disabled)
        button.setBackgroundColor(Color.purple400, for: .normal)
        button.layer.cornerRadius = 4
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(didTapDoneAction), for: .touchUpInside)
        button.isEnabled = false
        return button
    }()
    
    // MARK: - Private
    private let eventId: String?
}

extension CreateSocialCalendarView {
    func configure(with socialCalendar: EventDetailResponse) {
        doneButton.toggleEnabledState(textToChange: "수정 완료", true)
        titleTextInput.text = socialCalendar.title
        dateField.text = socialCalendar.date.format(with: "yyyy.MM.dd (E)")
        if socialCalendar.scheduleType == "행사" {
            categorySpaceView.isSelected = false
            categoryEventView.isSelected = true
        } else {
            categorySpaceView.isSelected = true
            categoryEventView.isSelected = false
        }
        if let imageURL = URL(string: "\(Url.imageBase(Table.events.rawValue))/\(socialCalendar.fileName)") {
            photoSlider.items = [HorizontalPhotoSlider.Item(reference: .url(imageURL), isMain: true)]
        }
        linkTextInput.text = socialCalendar.relatedLink
        descriptionInputLayout.setInputText(socialCalendar.detail)
    }
}

private extension CreateSocialCalendarView{
    func setupUI(){
        backgroundColor = Color.white
        
        addSubview(scrollView)
        scrollView.addSubview(scrollContainer)
        scrollContainer.addSubview(vStack)
        vStack.addArrangedSubview(titleInputLayout)
        vStack.addArrangedSubview(dateInputLayout)
        vStack.addArrangedSubview(categoryInputLayout)
        vStack.addArrangedSubview(photoInputLayout)
        vStack.addArrangedSubview(linkInputLayout)
        vStack.addArrangedSubview(descriptionInputLayout)
        scrollContainer.addSubview(doneButton)
        
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
            $0.top.equalTo(scrollContainer.snp.topMargin)
            $0.leading.equalTo(scrollContainer.snp.leadingMargin)
            $0.trailing.equalTo(scrollContainer.snp.trailingMargin)
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
        doneButton.snp.makeConstraints{
            $0.top.equalTo(vStack.snp.bottom).offset(48)
            $0.leading.equalTo(scrollContainer.snp.leadingMargin)
            $0.trailing.equalTo(scrollContainer.snp.trailingMargin)
            $0.bottom.equalTo(scrollContainer.snp.bottomMargin)
            $0.height.equalTo(52)
        }
    }
    
    @objc func didTapDoneAction(){
        if let eventId{
            guard let date = dateField.text?.toDate(with: "yyyy.MM.dd (E)") else { return }
            guard let detail = descriptionInputLayout.inputText() else { return }
            guard let imageReference = photoSlider.items.first?.reference else { return }
            let title = titleTextInput.text ?? ""
            let scheduleType = categoryEventView.isSelected ? "행사" : "공간"
            let relatedLink = linkTextInput.text ?? ""
            uploadImageAndReturnFileName(eventId: eventId, imageReference: imageReference) {[weak self] fileName in
                guard let self else { return }
                if let fileName {
                    let eventToUpdate = EventToUpdate(id: eventId, title: title, scheduleType: scheduleType, date: date, detail: detail, relatedLink: relatedLink, fileName: fileName)
                    didTapDone?(eventToUpdate)
                }
            }
        }else{
            didTapDone?(nil)
        }
    }
    
    @objc func didChangeLinkAction(){
        didChangeLink?(linkTextInput.text.ifNil(then: ""))
    }
    
    @objc func didChangeTitleAction(){
        didChangeTitle?(titleTextInput.text.ifNil(then: ""))
    }
    
    func convertPHAssetToData(asset: PHAsset, completion: @escaping (Data?) -> Void) {
        let imageManager = PHImageManager.default()
        let requestOptions = PHImageRequestOptions()
        requestOptions.isSynchronous = true
        requestOptions.deliveryMode = .highQualityFormat
        requestOptions.resizeMode = .exact
        
        let targetSize = CGSize(width: asset.pixelWidth, height: asset.pixelHeight)
        
        imageManager.requestImage(for: asset, targetSize: targetSize, contentMode: .aspectFill, options: requestOptions) { image, info in
            guard let image = image else {
                completion(nil)
                return
            }
            let imageData = image.jpegData(compressionQuality: 0.8)
            completion(imageData)
        }
    }
    
    func uploadImageAndReturnFileName(eventId: String, imageReference: ImageReference, completion: @escaping (String?) -> Void) {
        switch imageReference {
        case .url(let url):
            completion(url.urlToFileName())
        case.photo(let asset):
            convertPHAssetToData(asset: asset) { data in
                guard let data = data else {
                    print("convertPHAssetToData failed")
                    completion(nil)
                    return
                }
                Task {
                    let imageName = "\(UUID().uuidString).jpg"
                    let pathName = "\(eventId)/\(imageName)"
                    let isUploadingSuccess = await NetworkService.shared.uploadImage(pathName: pathName, data: data)
                    if isUploadingSuccess {
                        completion(pathName)
                    } else {
                        print("image uploading failed")
                        completion(nil)
                    }
                }
            }
        default:
            completion(nil)
        }
    }
    
    @objc func didTapSpace(){
        categorySpaceView.isSelected = true
        categoryEventView.isSelected = false
        
        didTapScheduleType?(.공간)
    }
    
    @objc func didTapEvent(){
        categorySpaceView.isSelected = false
        categoryEventView.isSelected = true
        
        didTapScheduleType?(.행사)
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
            let view = CreateSocialCalendarView(eventId: "0")
            return view
        }
    }
}
