//
//  InviteUserVC.swift
//  housetainer-ios
//
//  Created by 김수아 on 2/12/24.
//

import UIKit
import Combine

final class InviteUserVC: BaseViewController{
    
    private let vm = InviteUserVM()
    private var cancellables: [AnyCancellable] = []
    private var subscriptions = Set<AnyCancellable>()
 
    private let scrollView = {
        let scrollView = UIScrollView()
        return scrollView
    }()
    
    private let scrollContainer = {
        let view = UIView()
        view.layoutMargins = UIEdgeInsets(top: 16, left: 20, bottom: 16, right: 20)
        return view
    }()
    
    private let titleLabel = {
        let label = UILabel()
        label.font = Typo.Heading1()
        label.textColor = Color.black
        label.numberOfLines = 0
        label.text = """
        홈버디 초대
        """
        return label
    }()
    private let subtitleLabel = {
        let label = UILabel()
        label.font = Typo.Body2()
        label.textColor = Color.black
        label.numberOfLines = 0
        label.text = """
        좋은 친구를 홈버디로 등록하면 집초대 기회가 높아집니다.
        홈버디는 2명까지만 초대 가능해요!
        """
        return label
    }()
    
    private lazy var nameField: MyTextField = {
        let field = MyTextField(config: MyTextFieldConfig(label: nil, isLabelRequired: true, placeholder: "홈버디 이름", errMessage: "", limit: nil, keyboardType: .default))
        field.delegate = self
        return field
    }()
    
    private lazy var emailField: MyTextField =  {
        let field = MyTextField(config: MyTextFieldConfig(label: nil, isLabelRequired: true, placeholder: "홈버디 이메일", errMessage: ErrMessage.email, limit: nil, keyboardType: .default))
        field.delegate = self
        return field
    }()
    
    lazy var doneButton: UIButton = {
        let button = ButtonFactory.build(config: MyButtonConfig(title: "초대 이메일 보내기", font: Typo.Title4(), textColor: Color.gray500, bgColor: Color.gray200))
        button.isEnabled = false
        button.addTarget(self, action: #selector(didTapDoneAction), for: .touchUpInside)
        return button
    }()
    
    init() {
        super.init(nibName: nil, bundle: nil)
        setupUI()
        define()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCustomBackButton()
        vm.inviteUserPublisher
            .receive(on: DispatchQueue.main)
            .sink{ [weak self] inviteUser in
                guard let self else{ return }
                updateInviteUser(inviteUser)
                
                if inviteUser.isCompleted{
                    let vc = InviteUserCompleteVC()
                    vc.modalPresentationStyle = .fullScreen
                    navigationController?.present(vc, animated: true){ [weak self] in
                        guard let self else{ return }
                        navigationController?.popToRootViewController(animated: true)
                    }
                }
            }.store(in: &cancellables)
        
        Publishers
            .CombineLatest(nameField.textPublisher(), vm.isEmailValid)
            .receive(on: RunLoop.main)
            .sink { [unowned self] name, isEmailValid in
                guard let isEmailValid else { return }
                if !name.isEmptyOrWhitespace(), isEmailValid {
                    doneButton.toggleEnabledState(true)
                } else {
                    doneButton.toggleEnabledState(false)
                }
            }
            .store(in: &subscriptions)
        
        vm.isEmailValid
            .receive(on: RunLoop.main)
            .sink { [unowned self] isEmailValid in
                guard let isEmailValid else { return }
                if isEmailValid {
                    emailField.toggleError(hasError: false)
                } else {
                    emailField.toggleError(hasError: true)
                }
            }.store(in: &subscriptions)
        
        emailField.textPublisher()
            .receive(on: RunLoop.main)
            .sink { [unowned self] text in
                emailField.toggleError(hasError: false)
                vm.emailValidCheck(text)
            }
            .store(in: &subscriptions)
    }
}

private extension InviteUserVC {
    
    func updateInviteUser(_ inviteUser: InviteUser){
        if nameField.getText() != inviteUser.name{
            nameField.setText(inviteUser.name)
        }
        if emailField.getText() != inviteUser.email{
            nameField.setText(inviteUser.email)
        }
        doneButton.isEnabled = inviteUser.canUpdate
    }
    
    func setupUI(){
        view.backgroundColor = UIColor.white
        
        view.addSubview(scrollView)
        scrollView.addSubview(scrollContainer)
        scrollContainer.addSubview(titleLabel)
        scrollContainer.addSubview(subtitleLabel)
        scrollContainer.addSubview(nameField)
        scrollContainer.addSubview(emailField)
        view.addSubview(doneButton)
    }
    
    func define(){
        scrollView.snp.makeConstraints{
            $0.directionalEdges.equalToSuperview()
        }
        
        scrollContainer.snp.makeConstraints{
            $0.edges.width.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints{
            $0.top.equalTo(scrollContainer.snp.topMargin)
            $0.leadingMargin.equalTo(scrollContainer.snp.leadingMargin)
            $0.trailingMargin.equalTo(scrollContainer.snp.trailingMargin)
        }
        
        subtitleLabel.snp.makeConstraints{
            $0.top.equalTo(titleLabel.snp.bottom).offset(12)
            $0.leadingMargin.equalTo(scrollContainer.snp.leadingMargin)
            $0.trailingMargin.equalTo(scrollContainer.snp.trailingMargin)
        }
        
        nameField.snp.makeConstraints{
            $0.top.equalTo(subtitleLabel.snp.bottom).offset(24)
            $0.leadingMargin.equalTo(scrollContainer.snp.leadingMargin)
            $0.trailingMargin.equalTo(scrollContainer.snp.trailingMargin)
        }
        
        emailField.snp.makeConstraints{
            $0.top.equalTo(nameField.snp.bottom).offset(34)
            $0.leadingMargin.equalTo(scrollContainer.snp.leadingMargin)
            $0.trailingMargin.equalTo(scrollContainer.snp.trailingMargin)
            $0.bottom.equalTo(scrollContainer.snp.bottomMargin)
        }
        
        doneButton.snp.makeConstraints{
            $0.directionalHorizontalEdges.equalTo(view.safeAreaLayoutGuide.snp.directionalHorizontalEdges).inset(20)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(20)
        }
    }

    @objc func didTapDoneAction(){
        guard let name = nameField.getText(), let email = emailField.getText() else { return }
        vm.requestInvite(name: name, email: email)
    }
}

extension InviteUserVC: MyTextFieldDelegate {
    func clearButtonTapped() {
        doneButton.toggleEnabledState(false)
    }
}
