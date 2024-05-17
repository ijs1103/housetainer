//
//  AskingVC.swift
//  housetainer-ios
//
//  Created by 이주상 on 3/8/24.
//

import UIKit
import SnapKit
import Combine

final class AskingVC: BaseViewController {
    var initialTitle: String = ""{
        didSet {
            titleField.setText(initialTitle)
            titleField.isEnabled = false
            submitButton.toggleEnabledState(true)
        }
    }
    
    private let viewModel = AskingVM()
    private var subscriptions = Set<AnyCancellable>()

    private let askingTitleLabel: UILabel = {
        LabelFactory.build(text: "문의 제목", font: Typo.Title3(), textColor: Color.gray800, textAlignment: .left)
    }()
    
    private lazy var titleField: MyTextField = {
        let myTextField = MyTextField(config: MyTextFieldConfig(label: nil, isLabelRequired: false, placeholder: "제목을 입력해주세요.", errMessage: "", limit: 50, keyboardType: .default))
        myTextField.delegate = self
        return myTextField
    }()
    
    private let askingContentLabel: UILabel = {
        LabelFactory.build(text: "문의 내용", font: Typo.Title3(), textColor: Color.gray800, textAlignment: .left)
    }()

    private let contentTextView: MyTextView = {
        let textView = MyTextView()
        textView.placeholder = "문의하실 내용을 작성해주세요."
        textView.textLimit = 1000
        textView.snp.makeConstraints {
            $0.height.greaterThanOrEqualTo(360)
        }
        return textView
    }()
    
    private lazy var submitButton: UIButton = {
        let button = ButtonFactory.build(config: MyButtonConfig(title: "문의하기", font: Typo.Title4(), textColor: Color.gray500, bgColor: Color.gray200))
        button.isEnabled = false
        button.addTarget(self, action: #selector(didTapSubmitButton), for: .touchUpInside)
        return button
    }()
    
    private lazy var vStack: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [ askingTitleLabel, titleField, askingContentLabel, contentTextView, submitButton])
        stackView.axis = .vertical
        stackView.setCustomSpacing(12.0, after: askingTitleLabel)
        stackView.setCustomSpacing(20.0, after: titleField)
        stackView.setCustomSpacing(12.0, after: askingContentLabel)
        stackView.setCustomSpacing(60.0, after: contentTextView)
        return stackView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setUI()
        bind()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
}

extension AskingVC {
    
    func setupNavigationBar() {
        let customView = UIImageView(image: Icon.close)
        customView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapClose)))
        customView.isUserInteractionEnabled = true
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: customView)
        navigationItem.hidesBackButton = true
        let titleView = LabelFactory.build(text: "문의하기", font: Typo.Heading2(), textColor: Color.gray800)
        navigationItem.titleView = titleView
    }
    
    @objc private func didTapClose() {
        navigationController?.popViewController(animated: true)
    }

    private func setUI() {
        view.backgroundColor = .white
        
        [vStack].forEach {
            view.addSubview($0)
        }
        
        vStack.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.bottom.lessThanOrEqualTo(view.safeAreaLayoutGuide).offset(-25)
        }
    }
    
    @objc private func didTapSubmitButton() {
        guard let title = titleField.getText(), let content = contentTextView.text else { return }
        Task {
            await viewModel.ask(title: title, content: content)
        }
    }
    
    private func bind() {
        Publishers
            .CombineLatest(titleField.textPublisher(), contentTextView.textPublisher)
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
        
        viewModel.isAskingSuccess
            .receive(on: RunLoop.main)
            .sink { [unowned self] isAskingSuccess in
                guard let isAskingSuccess else { return }
                if isAskingSuccess {
                    PopUpModalVC.present(initialView: self, type: .asking, delegate: self)
                } else {
                    view.makeToast(ToastMessage.reportingFailed, duration: 3.0, position: .center)
                }
            }
            .store(in: &subscriptions)
    }
}

extension AskingVC: MyTextFieldDelegate {
    func clearButtonTapped() {
        submitButton.toggleEnabledState(false)
        titleField.toggleError(hasError: false)
    }
}

extension AskingVC: PopUpModalDelegate {
    func didTapOkButton() {
        self.dismiss(animated: true)
        navigationController?.popViewController(animated: true)
    }
}
