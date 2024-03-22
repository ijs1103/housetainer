//
//  SignupVC.swift
//  Housetainer
//
//  Created by 이주상 on 2023/11/13.
//

import UIKit
import SnapKit
import Combine
import Toast

final class SignupVC: UIViewController {
    
    private let viewModel = SignupVM()
    private var subscriptions = Set<AnyCancellable>()
    
    private let titleLabel: UILabel = {
        LabelFactory.build(text: Title.signup, font: Typo.Heading1())
    }()
    
    private let subtitleLabel: UILabel = {
        let label = LabelWithPadding(topInset: 16, bottomInset: 18, leftInset: 23, rightInset: 23)
        let style = NSMutableParagraphStyle()
        let lineheight = 20.0
        style.minimumLineHeight = lineheight
        style.maximumLineHeight = lineheight
        label.attributedText = NSAttributedString(
            string: Subtitle.signup,
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
    
    private lazy var checkBox: UIImageView = {
        let view = UIImageView(image: Icon.checkOff)
        let tgr = UITapGestureRecognizer(target: self, action: #selector(didTapCheckBox))
        view.addGestureRecognizer(tgr)
        view.isUserInteractionEnabled = true
        return view
    }()
    
    private let agreeLabel: UILabel = {
        LabelFactory.build(text: Title.agree, font: Typo.Title8())
    }()
    
    private lazy var hStack: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [ checkBox, agreeLabel])
        stackView.axis = .horizontal
        stackView.spacing = 9
        return stackView
    }()

    private let emailField = MyTextField(config: MyTextFieldConfig(label: Label.email, isLabelRequired: true, placeholder: Placeholder.email, errMessage: ErrMessage.email, limit: nil, keyboardType: .default))
    
    private let instaField = MyTextField(config: MyTextFieldConfig(label: Label.instagram, isLabelRequired: false, placeholder: Placeholder.instagram, errMessage: "", limit: nil, keyboardType: .default))
    
    private let etcField = MyTextField(config: MyTextFieldConfig(label: Label.etc, isLabelRequired: false, placeholder: Placeholder.etc, errMessage: "", limit: nil, keyboardType: .default))
    
    private lazy var magazineButton: UIStackView = {
        let label = UILabel()
        label.attributedText = NSMutableAttributedString().underlined(string: Title.magazine, font: Typo.Body3())
        let imageView = UIImageView(image: Icon.link)
        let stackView = UIStackView(arrangedSubviews: [ label, imageView])
        stackView.axis = .horizontal
        let tgr = UITapGestureRecognizer(target: self, action: #selector(didTapMagazineButton))
        stackView.addGestureRecognizer(tgr)
        stackView.isUserInteractionEnabled = true
        return stackView
    }()
    
    private lazy var vStack: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [ titleLabel, subtitleLabel, hStack, emailField, instaField, etcField, magazineButton])
        stackView.setCustomSpacing(16.0, after: subtitleLabel)
        stackView.setCustomSpacing(34.0, after: hStack)
        stackView.setCustomSpacing(40.0, after: instaField)
        stackView.setCustomSpacing(42.0, after: etcField)
        stackView.axis = .vertical
        stackView.alignment = .leading
        stackView.spacing = 12
        return stackView
    }()
    
    private lazy var getNewsButton: UIButton = {
        let button = ButtonFactory.build(config: MyButtonConfig(title: "소식받기", font: Typo.Title4(), textColor: Color.gray500, bgColor: Color.gray200))
        button.isEnabled = false
        button.addTarget(self, action: #selector(didTapGetNewsButton), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        setupCustomBackButton()
        setDelegates()
        bind()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
}

extension SignupVC {

    private func setUI() {
        [vStack, getNewsButton].forEach {
            view.addSubview($0)
        }
        
        vStack.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).inset(16)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        
        getNewsButton.snp.makeConstraints { make in
            make.height.equalTo(52)
            make.leading.trailing.equalToSuperview().inset(20)
            make.bottom.equalTo(view.safeAreaLayoutGuide).inset(20)
        }
    }
    
    @objc private func didTapMagazineButton() {
        let vc = WebViewController(urlString: Url.interStyleMagazine)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc private func didTapGetNewsButton() {
        guard let email = emailField.textField.text else { return }
        let snsUrl = etcField.textField.text
        let instagramId = instaField.textField.text
        let waiting = Waiting(email: email, snsUrl: snsUrl, instagramId: instagramId, createdAt: Date())
        Task {
            await viewModel.insertWaiting(waiting)
        }
    }
    
    @objc private func didTapCheckBox() {
        checkBox.image = (checkBox.image == Icon.checkOff) ? Icon.checkOn : Icon.checkOff
        viewModel.isChecked.send(checkBox.image == Icon.checkOn)
    }
    
    private func setDelegates() {
        emailField.delegate = self
    }
    
    private func bind() {
        viewModel.isEmailValid
            .receive(on: RunLoop.main)
            .sink { [unowned self] isEmailValid in
                guard let isEmailValid = isEmailValid else { return }
                if isEmailValid {
                    emailField.toggleError(hasError: false)
                } else {
                    emailField.toggleError(hasError: true)
                }
            }.store(in: &subscriptions)
        
        emailField.textField.publisher
            .receive(on: RunLoop.main)
            .sink { [unowned self] text in
                emailField.toggleError(hasError: false)
                viewModel.emailValidCheck(text)
            }
            .store(in: &subscriptions)
        
        viewModel.isFormValid
            .receive(on: RunLoop.main)
            .sink { [unowned self] isFormValid in
                if isFormValid {
                    getNewsButton.toggleEnabledState(true)
                } else {
                    getNewsButton.toggleEnabledState(false)
                }
            }.store(in: &subscriptions)
        
        viewModel.isInsertWaitingSuccessful
            .receive(on: RunLoop.main)
            .sink { [unowned self] isInsertWaitingSuccessful in
                guard let isInsertWaitingSuccessful else { return }
                view.makeToast(isInsertWaitingSuccessful ? ToastMessage.getNewsSuccess : ToastMessage.getNewsDuplicate, duration: 3.0, position: .center)
            }.store(in: &subscriptions)
    }
}

extension SignupVC: MyTextFieldDelegate {
    func clearButtonTapped() {
        getNewsButton.toggleEnabledState(false)
        emailField.toggleError(hasError: false)
    }
}
