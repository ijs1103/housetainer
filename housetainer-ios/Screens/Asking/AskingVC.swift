//
//  AskingVC.swift
//  housetainer-ios
//
//  Created by 이주상 on 3/8/24.
//

import UIKit
import SnapKit
import Combine

final class AskingVC: UIViewController {
    
    private var subscriptions = Set<AnyCancellable>()
    
    private let titleLabel: UILabel = {
        LabelFactory.build(text: Title.asking, font: Typo.Heading1())
    }()
    
    private lazy var titleField: MyTextField = {
        let myTextField = MyTextField(config: MyTextFieldConfig(label: nil, isLabelRequired: false, placeholder: "문의 제목", errMessage: "", limit: nil, keyboardType: .default))
        myTextField.delegate = self
        return myTextField
    }()
    
    private let contentInputLayout = {
        let inputLayout = InputLayout()
        inputLayout.spacing = 10
        inputLayout.inputViewBuilder = {
            let textField = MultiTextInput()
            textField.placeholder = """
            문의상세 내용 : (하단기입)
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
        let stackView = UIStackView(arrangedSubviews: [ titleLabel, titleField, contentInputLayout])
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

extension AskingVC {

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
        guard let title = titleField.textField.text, let content = contentInputLayout.inputText() else { return }
        Task {
            //TODO: 문의하기 api
        }
    }
    
    private func bind() {
        let contentPublisher = contentInputLayout.textPublisher()!
        let combinedPublisher = Publishers.CombineLatest(titleField.textField.publisher, contentPublisher)
        combinedPublisher
            .receive(on: RunLoop.main)
            .sink { [unowned self] title, content in
                // 제목, 내용 모두 입력하면 제출 버튼 활성화
                if !title.isEmptyOrWhitespace(), !content.isEmptyOrWhitespace() {
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

extension AskingVC: MyTextFieldDelegate {
    func clearButtonTapped() {
        submitButton.toggleEnabledState(false)
        titleField.toggleError(hasError: false)
    }
}
