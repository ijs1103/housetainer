//
//  NicknameVC.swift
//  Housetainer
//
//  Created by 이주상 on 2023/11/14.
//

import UIKit
import SnapKit
import Combine

final class NicknameVC: BaseViewController {
    
    private let viewModel: NicknameVM
    private var subscriptions = Set<AnyCancellable>()
    
    private let titleLabel: UILabel = {
        LabelFactory.build(text: Title.nickname, font: Typo.Heading1())
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        let style = NSMutableParagraphStyle()
        let lineheight = 22.0
        style.minimumLineHeight = lineheight
        style.maximumLineHeight = lineheight
        label.attributedText = NSAttributedString(
            string: Subtitle.nickname,
            attributes: [
                .paragraphStyle: style
            ])
        label.font = Typo.Body2()
        label.textColor = .black
        label.numberOfLines = 2
        label.textAlignment = .left
        return label
    }()
    
    private lazy var myTextField: MyTextField = {
        let textField = MyTextField(config: MyTextFieldConfig(label: nil, isLabelRequired: false, placeholder: Placeholder.nickname, errMessage: ErrMessage.nickname, limit: 10, keyboardType: .default))
        textField.delegate = self
        return textField
    }()
    
    private lazy var vStack: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [ titleLabel, subtitleLabel, myTextField])
        stackView.setCustomSpacing(32.0, after: subtitleLabel)
        stackView.axis = .vertical
        stackView.alignment = .leading
        stackView.spacing = 12
        return stackView
    }()
    
    private lazy var registerButton: UIButton = {
        let button = ButtonFactory.build(config: MyButtonConfig(title: Title.nicknameRegister, font: Typo.Title4(), textColor: Color.gray500, bgColor: Color.gray200))
        button.isEnabled = false
        button.addTarget(self, action: #selector(didTapRegisterButton), for: .touchUpInside)
        return button
    }()
    
    init(inviterId: String?) {
        self.viewModel = NicknameVM(inviterId: inviterId)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hidesBackButton()
        setUI()
        bind()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
}

extension NicknameVC {
    
    private func setUI() {
        view.backgroundColor = .white
        [vStack, registerButton].forEach {
            view.addSubview($0)
        }
        
        vStack.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).inset(16)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        
        registerButton.snp.makeConstraints { make in
            make.height.equalTo(52)
            make.leading.trailing.equalToSuperview().inset(20)
            make.bottom.equalTo(view.safeAreaLayoutGuide).inset(20)
        }
    }
    
    @objc private func didTapRegisterButton() {
        guard let nickname = myTextField.getText() else { return }
        Task {
            await viewModel.registerMember(nickname: nickname)
        }
    }
    
    private func bind() {
        myTextField.textPublisher()
            .receive(on: RunLoop.main)
            .sink { [unowned self] text in
                handleTextFieldChanging(text: text)
            }
            .store(in: &subscriptions)
        
        viewModel.isMemberRegistered
            .receive(on: RunLoop.main)
            .sink { [unowned self] isMemberRegistered in
                guard let isMemberRegistered else { return }
                if isMemberRegistered {
                    if let nickname = myTextField.getText(), viewModel.inviterId == nil {
                        view.makeToast(ToastMessage.specialGuestWelcome(nickname: nickname), duration: 3.0, position: .center) { _ in
                            self.dismiss(animated: true)
                        }
                    } else {
                        dismiss(animated: true)
                    }
                }
            }
            .store(in: &subscriptions)
        
        viewModel.isNicknameDuplicate
            .receive(on: RunLoop.main)
            .sink { [unowned self] isNicknameDuplicate in
                guard let isNicknameDuplicate else { return }
                if isNicknameDuplicate {
                    myTextField.toggleError(hasError: true)
                }
            }
            .store(in: &subscriptions)
    }
    
    private func handleTextFieldChanging(text: String) {
        myTextField.toggleError(hasError: false)
        if RegexHelper.matchesRegex(text, regex: Regex.nickname), text.count <= 10 {
            registerButton.toggleEnabledState(true)
        } else {
            registerButton.toggleEnabledState(false)
        }
    }
}

extension NicknameVC: MyTextFieldDelegate {
    func clearButtonTapped() {
        registerButton.toggleEnabledState(false)
        myTextField.toggleError(hasError: false)
        myTextField.resignFirstResponder()
    }
}
