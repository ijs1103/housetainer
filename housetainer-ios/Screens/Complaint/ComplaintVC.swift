//
//  ComplaintVC.swift
//  housetainer-ios
//
//  Created by 이주상 on 3/7/24.
//

import UIKit
import SnapKit
import Combine

final class ComplaintVC: UIViewController {
    
    private var subscriptions = Set<AnyCancellable>()
    
    private let titleLabel: UILabel = {
        LabelFactory.build(text: Title.complaint, font: Typo.Heading1())
    }()

    private let subtitleLabel: UILabel = {
        let label = LabelWithPadding(topInset: 16, bottomInset: 18, leftInset: 23, rightInset: 23)
        let style = NSMutableParagraphStyle()
        let lineheight = 20.0
        style.minimumLineHeight = lineheight
        style.maximumLineHeight = lineheight
        label.attributedText = NSAttributedString(
            string: Subtitle.complaint,
          attributes: [
            .paragraphStyle: style
          ])
        label.font = Typo.Body3()
        label.backgroundColor = Color.yellow100
        label.textColor = Color.yellow300
        label.layer.cornerRadius = 12
        label.clipsToBounds = true
        label.numberOfLines = 2
        label.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width).isActive = true
        return label
    }()
    
    private lazy var nicknameField: MyTextField = {
        let myTextField = MyTextField(config: MyTextFieldConfig(label: nil, isLabelRequired: false, placeholder: "신고대상 닉네임", errMessage: "", limit: nil, keyboardType: .default))
        myTextField.delegate = self
        return myTextField
    }()
    
    private lazy var reasonField: MyTextField = {
        let myTextField = MyTextField(config: MyTextFieldConfig(label: nil, isLabelRequired: false, placeholder: "신고사유", errMessage: "", limit: nil, keyboardType: .default))
        myTextField.delegate = self
        return myTextField
    }()
    
    private let contentInputLayout = {
        let inputLayout = InputLayout()
        inputLayout.spacing = 10
        inputLayout.inputViewBuilder = {
            let textField = MultiTextInput()
            textField.placeholder = """
            신고상세 내용 : (하단기입)
            최대 1000자
            """
            textField.snp.makeConstraints{
                $0.height.greaterThanOrEqualTo(192)
            }
            return textField
        }
        return inputLayout
    }()
    
    private lazy var submitButton: UIButton = {
        let button = ButtonFactory.build(config: MyButtonConfig(title: "제출", font: Typo.Title4(), textColor: Color.gray500, bgColor: Color.gray200))
        button.isEnabled = false
        button.addTarget(self, action: #selector(didTapSubmitButton), for: .touchUpInside)
        return button
    }()
    
    private lazy var vStack: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [ titleLabel, subtitleLabel, nicknameField, reasonField, contentInputLayout])
        stackView.setCustomSpacing(16.0, after: titleLabel)
        stackView.setCustomSpacing(16.0, after: nicknameField)
        stackView.axis = .vertical
        stackView.alignment = .leading
        stackView.spacing = 32
        return stackView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCloseButton()
        setUI()
        bind()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
}

extension ComplaintVC {

    private func setUI() {
        [vStack, submitButton].forEach {
            view.addSubview($0)
        }
        
        vStack.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        
        contentInputLayout.snp.makeConstraints { make in
            make.width.equalToSuperview()
        }
        
        submitButton.snp.makeConstraints { make in
            make.top.greaterThanOrEqualTo(vStack.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
            make.bottom.equalTo(view.safeAreaLayoutGuide).inset(20)
        }
    }
    
    @objc private func didTapSubmitButton() {
        guard let nickName = nicknameField.textField.text, let reason = reasonField.textField.text, let content = contentInputLayout.inputText() else { return }
        Task {
            //TODO: 신고하기 api
        }
    }
    
    private func bind() {
        let contentPublisher = contentInputLayout.textPublisher()!
        let combinedPublisher = Publishers.CombineLatest3(nicknameField.textField.publisher, reasonField.textField.publisher, contentPublisher)
        combinedPublisher
            .receive(on: RunLoop.main)
            .sink { [unowned self] nickname, reason, content in
                // 닉네임, 사유, 내용 모두 입력하면 제출 버튼 활성화
                if !nickname.isEmptyOrWhitespace(), !reason.isEmptyOrWhitespace(), !content.isEmptyOrWhitespace() {
                    submitButton.toggleEnabledState(true)
                } else {
                    submitButton.toggleEnabledState(false)
                }
            }
            .store(in: &subscriptions)
    }
    
    func setupCloseButton() {
        let customView = UIImageView(image: Icon.close)
        let tgr = UITapGestureRecognizer(target: self, action: #selector(didTapClose))
        customView.addGestureRecognizer(tgr)
        customView.isUserInteractionEnabled = true
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: customView)
        navigationItem.hidesBackButton = true
    }
    
    @objc private func didTapClose() {
        navigationController?.popViewController(animated: false)
    }
}

extension ComplaintVC: MyTextFieldDelegate {
    func clearButtonTapped() {
        submitButton.toggleEnabledState(false)
        nicknameField.toggleError(hasError: false)
        reasonField.toggleError(hasError: false)
    }
}
