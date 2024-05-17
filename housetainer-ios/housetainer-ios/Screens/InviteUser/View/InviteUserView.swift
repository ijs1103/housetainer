//
//  InviteUserView.swift
//  housetainer-ios
//
//  Created by 김수아 on 2/12/24.
//

import Foundation
import SnapKit
import UIKit
import SwiftUI

final class InviteUserView: UIView{
    var didChangeName: ((String) -> Void)?
    var didChangeEmail: ((String) -> Void)?
    var didTapDone: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        define()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeFrame), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit{
        NotificationCenter.default.removeObserver(self)
    }
    
    func updateInviteUser(_ inviteUser: InviteUser){
        if nameField.getText() != inviteUser.name{
            nameField.setText(inviteUser.name)
        }
        if emailField.getText() != inviteUser.email{
            nameField.setText(inviteUser.email)
        }
        doneButton.isEnabled = inviteUser.canUpdate
    }
    
    // MARK: - UI Properties
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
    
    private let nameField = MyTextField(config: MyTextFieldConfig(label: nil, isLabelRequired: true, placeholder: "홈버디 이름", errMessage: "", limit: nil, keyboardType: .default))
    
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
    
    // MARK: Private
}

private extension InviteUserView{
    func setupUI(){
        backgroundColor = Color.white
        
        addSubview(scrollView)
        scrollView.addSubview(scrollContainer)
        scrollContainer.addSubview(titleLabel)
        scrollContainer.addSubview(subtitleLabel)
        scrollContainer.addSubview(nameField)
        scrollContainer.addSubview(emailField)
        addSubview(doneButton)
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
            $0.directionalHorizontalEdges.equalTo(safeAreaLayoutGuide.snp.directionalHorizontalEdges).inset(20)
            $0.bottom.equalTo(safeAreaLayoutGuide.snp.bottom).inset(20)
        }
    }
    
        
    @objc func keyboardWillChangeFrame(_ notification: NSNotification){
        guard
            let userInfo = notification.userInfo,
            let endFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect
        else{ return }
        let keyboardHeight: CGFloat = if let screenHeight = window?.screen.bounds.height{
            max(0, screenHeight - endFrame.minY - self.safeAreaInsets.bottom)
        }else{
            0
        }
        doneButton.snp.updateConstraints{
            $0.bottom.equalTo(safeAreaLayoutGuide.snp.bottom).inset(keyboardHeight + 20)
        }
        scrollView.contentInset.bottom = keyboardHeight - self.safeAreaInsets.bottom + doneButton.frame.height + 20
    }
    
    @objc func didChangeNameAction(){
        didChangeName?(nameField.getText() ?? "")
    }
    @objc func didChangeEmailAction(){
        didChangeEmail?(emailField.getText() ?? "")
    }
    @objc func didTapDoneAction(){
        didTapDone?()
    }
}

extension InviteUserView: MyTextFieldDelegate {
    func clearButtonTapped() {
        doneButton.toggleEnabledState(false)
    }
}

struct InviteUserView_Previews: PreviewProvider{
    static var previews: some View{
        ViewPreview{
            let view = InviteUserView()
            return view
        }
    }
}
