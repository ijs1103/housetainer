//
//  InviteVC.swift
//  Housetainer
//
//  Created by 이주상 on 2023/11/09.
//

import UIKit
import SnapKit
import Combine
import Toast

final class InviteVC: UIViewController {
    
    private let isProviderApple: Bool
    private let viewModel = InviteVM()
    private var subscriptions = Set<AnyCancellable>()
    
    private let titleLabel: UILabel = {
        LabelFactory.build(text: Title.invite, font: Typo.Heading1())
    }()
    
    private let subtitleLabel: UILabel = {
        LabelFactory.build(text: Subtitle.invite, font: Typo.Body2(), textAlignment: .left)
    }()
    
    private lazy var myTextField: MyTextField = {
        let myTextField = MyTextField(config: MyTextFieldConfig(label: nil, isLabelRequired: false, placeholder: Placeholder.invite, errMessage: ErrMessage.invte, limit: nil, keyboardType: .numberPad))
        myTextField.delegate = self
        return myTextField
    }()
    
    private let noInviteButton = CtaButton(title: Title.noInvite)
        
    private lazy var verifyButton: UIButton = {
        let button = ButtonFactory.build(config: MyButtonConfig(title: Title.verify, font: Typo.Title4(), textColor: Color.gray500, bgColor: Color.gray200))
        button.isEnabled = false
        button.addTarget(self, action: #selector(didTapVerifyButton), for: .touchUpInside)
        return button
    }()
    
    private lazy var vStack: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [ titleLabel, subtitleLabel, myTextField, noInviteButton])
        stackView.setCustomSpacing(32.0, after: subtitleLabel)
        stackView.setCustomSpacing(16.0, after: myTextField)
        stackView.axis = .vertical
        stackView.alignment = .leading
        stackView.spacing = 12
        return stackView
    }()
    
    init(isProviderApple: Bool = false) {
        self.isProviderApple = isProviderApple
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCloseButton()
        setUI()
        setDelegates()
        bind()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
}

extension InviteVC {

    private func setUI() {
        [vStack, verifyButton].forEach {
            view.addSubview($0)
        }
        
        vStack.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).inset(16)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        
        verifyButton.snp.makeConstraints { make in
            make.top.greaterThanOrEqualTo(vStack.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
            make.bottom.equalTo(view.safeAreaLayoutGuide).inset(20)
        }
    }
    
    @objc private func didTapVerifyButton() {
        guard let code = myTextField.textField.text else { return }
        Task {
            await viewModel.verifyInvitationCode(with: code, isProviderApple: isProviderApple)
        }
    }
    
    private func setDelegates() {
        noInviteButton.delegate = self
    }
    
    private func bind() {
        myTextField.textField.publisher
            .receive(on: RunLoop.main)
            .sink { [unowned self] text in
                // 6자리 숫자를 입력해야만 초대코드 인증버튼이 활성화
                if !text.isEmpty, RegexHelper.matchesRegex(text, regex: Regex.inviteCode) {
                    verifyButton.toggleEnabledState(true)
                } else {
                    verifyButton.toggleEnabledState(false)
                }
            }
            .store(in: &subscriptions)
        
        viewModel.isCodeExpired
            .receive(on: RunLoop.main)
            .sink { [unowned self] isCodeExpired in
                guard let isCodeExpired else { return }
                if isCodeExpired {
                    myTextField.toggleError(hasError: true)
                } else {
                    navigationController?.pushViewController(NicknameVC(), animated: true)
                }
            }
            .store(in: &subscriptions)
        
        viewModel.isInvitationExisting
            .receive(on: RunLoop.main)
            .sink { [unowned self] isInvitationExisting in
                guard let isInvitationExisting else { return }
                if !isInvitationExisting {
                    view.makeToast(ToastMessage.notExistingInvitation, duration: 3.0, position: .center)
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
        viewModel.kakaoNaverSignOut()
        NetworkService.shared.supabaseSignOut()
        navigationController?.popViewController(animated: false)
    }
}

extension InviteVC: CtaButtonDelegate {
    func didTapCtaButton(title: String) {
        navigationController?.pushViewController(SignupVC(), animated: true)
    }
}

extension InviteVC: MyTextFieldDelegate {
    func clearButtonTapped() {
        verifyButton.toggleEnabledState(false)
        myTextField.toggleError(hasError: false)
    }
}
